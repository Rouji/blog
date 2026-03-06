# nginx
route root to a language based on accept-language:
```
map $http_accept_language $lang {
    default en;
    ~*^en en;
    ~*^ja ja;
    ~*^de de;
}

[...] 

location ~ /.+ {
    try_files $uri $uri/ =404;
}

location / {
    return 302 /$lang$request_uri;
}
```
