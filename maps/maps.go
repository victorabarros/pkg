package maps

// Copy return a deepCopy from inputed map
// inspired on: https://stackoverflow.com/a/53062590
func Copy(m map[string]interface{}) map[string]interface{} {
	cp := make(map[string]interface{})
	for k, v := range m {
		vm, ok := v.(map[string]interface{})
		if ok {
			cp[k] = Copy(vm)
		} else {
			cp[k] = v
		}
	}

	return cp
}
