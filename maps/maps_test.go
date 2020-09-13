package maps

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestCopyMap(t *testing.T) {
	tests := []map[string]interface{}{
		map[string]interface{}{
			"a": "bbb",
			"b": map[string]interface{}{
				"c": 123,
			},
		},
		map[string]interface{}{
			"r": 1,
			"t": 0,
		},
		map[string]interface{}{
			"r": true,
			"t": false,
		},
	}

	for _, in := range tests {
		cp := Copy(in)
		require.Equal(t, cp, in)
	}
}
