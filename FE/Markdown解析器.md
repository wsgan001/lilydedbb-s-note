# Markdown解析器

### ```md2html.js```

```javascript
/**
 * Created by dbb on 2016/12/24.
 */
function Markdowm() {
    this.md = [];
    this.i = 0;
    this.html = "";
    this.codeArea = false;

    this.REGEXP_IMG = /(\!\[[^\f\n\r\t\v\[\]]+\]){1}(\([\w:\/\.]+\)){1}/;
    this.REGEXP_LINK = /(\[[^\f\n\r\t\v\[\]]+\]){1}(\([\w:\/\.]+\)){1}/;

    this.init = function (text) {
        this.md = text;
        console.log(this.md);
    };

    this.md2html = function () {
        for( ; this.i < this.md.length; this.i++){
            if(/^#+/.test(this.md[this.i])){ // h1, h2, h3, h4, h5, h6
                this.h(this.md[this.i]);
                continue;
            }else if(/^-{3,}/.test(this.md[this.i])){ // </hr>
                this.hr(this.md[this.i]);
                continue;
            }else if((/^```[a-zA-Z]*/.test(this.md[this.i]) && !/```$/.test(this.md[this.i])) || this.md[this.i] == "```"){ // <pre>
                this.code();
                continue;
            }else if(/^(>|&gt;)/.test(this.md[this.i])){ // <blockquote>
                this.blockquote(this.md[this.i]);
                continue;
            }else if(/\*\s+/.test(this.md[this.i])){ // <li>
                this.html += this.li(this.md[this.i]);
                continue;
            }else if(this.REGEXP_LINK.test(this.md[this.i])){ // <a>
                if(this.REGEXP_IMG.test(this.md[this.i])){ // <img>
                    this.html += this.img(this.md[this.i]);
                    continue;
                }
                this.html += this.a(this.md[this.i]);
                continue;
            }else if(/```\S*```/.test(this.md[this.i])){ // <span>
                this.html += this.span(this.md[this.i]);
                continue;
            }else if(/\*\*/.test(this.md[this.i])){ // <b>
                this.html += this.b(this.md[this.i]);
                continue;
            }
            this.html += this.md[this.i].trim();
        }
    };

    this.renderHtml = function () {
        this.md2html();
        return this.html;
    };

}

// h1, h2, h3, h4, h5, h6
Markdowm.prototype.h = function (md) {
    md = md.trim();
    var _html = "";
    for(var i = 1; i <= 6; i++){
        var reStr = "^#{" + i + "}"; // 匹配hi
        var re = new RegExp(reStr);
        if(re.test(md)){
            _html = "<h" + i + ">" + md.replace(/^#+/, "").trim() + "</h" + i + ">"
        }
    }
    this.html += _html;
};

// </hr>
Markdowm.prototype.hr = function (md) {
    md = md.replace(" ", ""); // 去掉其中的空格
    if(/(!-)+/.test(md)) // 如果有任何非'—'的字符，则不符合
        return;
    if(/^-{3,}/.test(md))
        this.html += "<hr></hr>";
};

// <pre>
Markdowm.prototype.code = function (md) {
    this.html += "<pre class=\"code " + this.md[this.i++].trim().replace("```", "") + "\">";
    while (!/```$/.test(this.md[this.i])){
        this.html += this.md[this.i] + "\n";
        this.i++;
    }
    this.html += this.md[this.i].replace(/```$/, "") + "</pre>";
};

// <blockquote>
Markdowm.prototype.blockquote = function (md) {
    this.html += "<blockquote>" + this.li(md.replace(/^(>|&gt;)/, "")) + "\n";
    while (/^(>|&gt;)/.test(this.md[++this.i])){
        this.html += this.li(this.md[this.i].replace(/^(>|&gt;)/, "")) + "\n";
    }
    this.html += "</blockquote>";
};

// <li>
Markdowm.prototype.li = function (md) {
    if(/\*\s+/.test(md)){
        return "<li>" + this.a(md.replace(/\*\s+/, "").trim()) + "</li>";
    }else{
        return this.span(md);
    }
};

// <img>
Markdowm.prototype.img = function (md) {
    var _html = "";
    var arr = md.split(this.REGEXP_IMG);
    if(arr.length == 1)
        return md;
    _html = this.a(arr[0]) + "<img src=\"" + arr[2].replace(/^\(/, "").replace(/\)$/, "") + "\" alt=\"" + arr[1].replace(/^\!\[/, "").replace(/\]$/, "") + "\"></img>" + this.a(arr[3]);
    return _html;
};

// <a>
Markdowm.prototype.a = function (md) {
    var _html = "";
    var arr = md.split(this.REGEXP_LINK);
    if(arr.length == 1)
        return md;
    _html = this.span(arr[0]) + "<a href=\"" + arr[2].replace(/^\(/, "").replace(/\)$/, "") + "\">" + this.span(arr[1].replace(/^\[/, "").replace(/\]$/, "")) + "</a>" + this.span(arr[3]);
    return _html;
};

// <span>
Markdowm.prototype.span = function (md) {
    var _index = 0;
    var _arr = md.split("```");
    var _html = "";
    while (_index < _arr.length){
        _html += (_index % 2 == 0) ? this.b(_arr[_index]) : "<span class=\"code-span\">" + this.b(_arr[_index]) + "</span>";
        _index++;
    }
    return _html;
};

// <b>
Markdowm.prototype.b = function (md) {
    var _index = 0;
    var _arr = md.split("**");
    var _html = "";
    while (_index < _arr.length){
        _html += (_index % 2 == 0) ? _arr[_index] : "<b>" + _arr[_index] + "</b>";
        _index++;
    }
    return _html;
};
```

### ```markdown.css```

```css
h1, h2, h3, h4, h5, h6{
    font-weight: 600;
    line-height: 1.5;
    margin: 0;
}

.markdown h1{
    font-size: 32px;
}

.markdown h2{
    font-size: 26px;
}

.markdown h3{
    font-size: 22px;
}

.markdown h4{
    font-size: 18px;
}

.markdown h5{
    font-size: 15px;
}

.markdown h6{
    font-size: 12px;
}

.markdown .code-span{
    display: inline-block;
    margin: 0 4px;
    padding: 2px 5px;
    background-color: #ddd;
    font-family: monospace, monospace;
    border-radius: 3px;
    min-height: 22px;
}

.markdown pre.code {
    margin: 10px;
    line-height: 20px;
    padding: 5px 10px;
    background-color: #ddd;
    overflow-x: scroll;
    border-radius: 5px;
    min-height: 30px;
}

.markdown blockquote{
    white-space: pre;
    border-left: 5px solid silver;
    background-color: #ddd;
    margin: 10px;
    padding: 10px 15px;
}

.markdown li{
    list-style: disc;
    padding-left: 15px;
    line-height: 24px;
}

.markdown a{
    text-decoration: none;
    color: dodgerblue;
}

.markdown a:hover{
    cursor: pointer;
    text-decoration: underline;
}

.markdown b{
    font-weight: bold !important;
}
```

