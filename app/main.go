package main

import (
	"net/http"
	"net/http/httputil"

	"github.com/gin-gonic/gin"
)

func requestDump(c *gin.Context) {

	requestDump, err := httputil.DumpRequest(c.Request, true)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err})
		return
	}
	c.JSON(http.StatusOK,
		gin.H{
			"dump": string(requestDump),
		})
}

func setupRouter() *gin.Engine {
	r := gin.Default()

	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "ok",
		})
	})
	r.GET("/dump", requestDump)
	r.GET("/dump/:id", requestDump)

	return r
}

func main() {
	router := setupRouter()

	router.Run(":8088")
}
