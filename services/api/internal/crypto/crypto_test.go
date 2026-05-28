package crypto_test

import (
	"crypto/rand"
	"encoding/base64"
	"io"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/crypto"
)

func newRandomKey(t *testing.T) []byte {
	t.Helper()
	key := make([]byte, 32)
	_, err := io.ReadFull(rand.Reader, key)
	require.NoError(t, err)
	return key
}

func TestSealOpen_RoundTrip(t *testing.T) {
	t.Parallel()
	s, err := crypto.New(newRandomKey(t))
	require.NoError(t, err)

	cases := []struct {
		name      string
		plaintext []byte
	}{
		{"short", []byte("hello")},
		{"binary", []byte{0x00, 0xff, 0xde, 0xad, 0xbe, 0xef}},
		{"longer", []byte("source-credential blob with some length to exceed one AES block")},
	}
	for _, tc := range cases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			ct, err := s.Seal(tc.plaintext)
			require.NoError(t, err)
			require.NotEqual(t, tc.plaintext, ct, "ciphertext must differ from plaintext")

			pt, err := s.Open(ct)
			require.NoError(t, err)
			require.Equal(t, tc.plaintext, pt)
		})
	}
}

func TestSeal_FreshNoncePerCall(t *testing.T) {
	t.Parallel()
	s, err := crypto.New(newRandomKey(t))
	require.NoError(t, err)
	a, err := s.Seal([]byte("same input"))
	require.NoError(t, err)
	b, err := s.Seal([]byte("same input"))
	require.NoError(t, err)
	require.NotEqual(t, a, b, "fresh nonce → different ciphertexts for same plaintext")
}

func TestOpen_RejectsTamperedCiphertext(t *testing.T) {
	t.Parallel()
	s, err := crypto.New(newRandomKey(t))
	require.NoError(t, err)
	ct, err := s.Seal([]byte("integrity"))
	require.NoError(t, err)
	ct[len(ct)-1] ^= 0x01 // flip a bit in the auth tag region
	_, err = s.Open(ct)
	require.Error(t, err, "tampered ciphertext should fail GCM auth")
}

func TestOpen_RejectsTooShort(t *testing.T) {
	t.Parallel()
	s, err := crypto.New(newRandomKey(t))
	require.NoError(t, err)
	_, err = s.Open([]byte{0x00})
	require.ErrorIs(t, err, crypto.ErrCiphertextTooShort)
}

func TestNew_RejectsBadKeySize(t *testing.T) {
	t.Parallel()
	_, err := crypto.New(make([]byte, 16))
	require.Error(t, err, "16-byte key must be rejected (AES-256 needs 32)")
}

func TestNewFromEnv_RoundTrip(t *testing.T) {
	key := newRandomKey(t)
	t.Setenv(crypto.KeyEnvVar, base64.StdEncoding.EncodeToString(key))
	s, err := crypto.NewFromEnv()
	require.NoError(t, err)

	ct, err := s.Seal([]byte("env-loaded"))
	require.NoError(t, err)
	pt, err := s.Open(ct)
	require.NoError(t, err)
	require.Equal(t, []byte("env-loaded"), pt)
}

func TestNewFromEnv_FailsClosed(t *testing.T) {
	t.Setenv(crypto.KeyEnvVar, "")
	_, err := crypto.NewFromEnv()
	require.Error(t, err)
}
