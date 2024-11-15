package utils

import (
	"log"
	"path/filepath"
	"runtime"
)

func GetFilePath() string {
	// 現在のファイルのディレクトリを取得
	_, filename, _, ok := runtime.Caller(0)
	if !ok {
		log.Fatal("Failed to get caller information")
	}
	dir := filepath.Dir(filename) // ファイルのディレクトリパスを取得
	return dir
}
