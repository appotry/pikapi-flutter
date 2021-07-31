package utils

import (
	"hash/fnv"
	"sync"
)

var hashMutex []*sync.Mutex

func init() {
	for i := 0; i < 16; i++ {
		hashMutex = append(hashMutex, &sync.Mutex{})
	}
}

func HashLock(key string) *sync.Mutex {
	hash := fnv.New32()
	hash.Write([]byte(key))
	return hashMutex[int(hash.Sum32()%uint32(len(hashMutex)))]
}
