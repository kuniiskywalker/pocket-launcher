package main

import (
    "github.com/PuerkitoBio/goquery"
    "github.com/otiai10/cachely"
    "fmt"
    "time"
    "strings"
    "net/http"
    "io/ioutil"
)

type Result struct {
     Url string
}

func handler(w http.ResponseWriter, r *http.Request) {

    url := r.FormValue("url")
    if url == "" {
        http.Error(w, "url required.", http.StatusBadRequest)
        return
    }

    html := GetPage(url)
    reader := strings.NewReader(html)
    doc, _ := goquery.NewDocumentFromReader(reader)
    
    dom := doc.Find("body p")
    dom.Find("pre").Remove()
    dom.Find("script").Remove()

    text := dom.Text()
    
    text = strings.TrimSpace(text)
    fmt.Fprintf(w, text)
}

func GetPage(url string) string {
  cachely.Expires(200 * time.Millisecond)

  res, _ := cachely.Get(url)

  byteArray, _ := ioutil.ReadAll(res.Body)
  return string(byteArray)
}

func main() {
    http.HandleFunc("/", handler)
    http.ListenAndServe("0.0.0.0:8080", nil)
}
