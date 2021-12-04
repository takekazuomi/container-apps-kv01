package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func TestDumpWithBody(t *testing.T) {
	router := setupRouter()

	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	s := "1234"
	r := fmt.Sprintf("{\"body\":\"%s\"}", s)

	req, err := http.NewRequest("GET", "/dump", strings.NewReader(s))
	if err != nil {
		log.Printf("error: %v", err)
	}

	c.Request = req

	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)

	body, _ := io.ReadAll(w.Result().Body)
	assert.Equal(t, r, string(body))
}

func TestDump(t *testing.T) {
	router := setupRouter()

	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)

	s := ""
	r := fmt.Sprintf("{\"body\":\"%s\"}", s)

	req, _ := http.NewRequest("GET", "/dump", nil)

	c.Request = req

	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)

	body, _ := io.ReadAll(w.Result().Body)
	assert.Equal(t, r, string(body))
}
