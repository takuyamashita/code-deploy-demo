package main

import (
	"app/middleware"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var logger *zap.Logger

func main() {

	currentDir, _ := os.Getwd()

	_, err := os.OpenFile(fmt.Sprintf("%s/%s", currentDir, "gin.log"), os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
	if err != nil {
		log.Fatal(err)
	}

	encoderConfig := zap.NewProductionEncoderConfig()
	encoderConfig.TimeKey = "timestamp"
	encoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder

	config := zap.NewProductionConfig()
	config.EncoderConfig = encoderConfig
	config.OutputPaths = []string{"gin.log"}
	config.DisableStacktrace = false

	logger, err = config.Build()
	if err != nil {
		log.Fatal(err)
	}

	defer logger.Sync()

	r := gin.New()
	r.Use(middleware.Logger(logger))
	r.GET("/api/message", hello)
	r.Run("[::]:80")
}

func hello(c *gin.Context) {

	logger.Info("hello world")
	logger.Error("error")

	c.JSON(http.StatusOK, map[string]string{"message": "Hello, World!"})
}
