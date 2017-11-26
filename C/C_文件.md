# C 文件

### `fopen()`

`fopen()` 函数用来打开一个文件，它的原型为：

```c
FILE *fopen(char *filename, char *mode);
```

文件打开方式由 `r`、`w`、`a`、`t`、`b`、`+` 六个字符拼成，各字符的含义是：

- r(read)：读
- w(write)：写
- a(append)：追加
- t(text)：文本文件，可省略不写
- b(banary)：二进制文件
- +：读和写

**如果没有 `b` 字符，文件以文本方式打开**

**凡用 `r` 打开一个文件时，该文件必须已经存在**

在打开一个文件时，如果出错，`fopen` 将返回一个空指针值 `NULL`。在程序中可以用这一信息来判别是否完成打开文件的工作，并作相应的处理

因此常用以下程序段打开文件：

```c
if ((fp = fopen("D:\\demo.txt","rb") == NULL ) {
    printf("Error on open D:\\demo.txt file!");
    getch();
    exit(1);
}
```

### `fclose()`

```c
int fclose(FILE *fp);
```

### `fgetc`

字符读取函数 `fgetc` 是从指定的文件中读取一个字符

```c
int fgetc (FILE *fp);
```

`fgetc()` 读取成功时返回读取到的字符，读取到文件末尾或读取失败时返回 `EOF`

```c
// 每次读取一个字节，直到读取完毕
char ch;
while ((ch = fgetc(fp)) != EOF) {
	putchar(ch);
}
```

### `fputc`

```c
char ch;
while ((ch = getchar()) != EOF) {
	fputc(ch, fp);
}
```

### `fgets`

```c
char *fgets ( char *str, int n, FILE *fp );
```

返回值：读取成功时返回字符数组首地址，也即 str；读取失败时返回 NULL；如果开始读取时文件内部指针已经指向了文件末尾，那么将读取不到任何字符，也返回 NULL

### `fputs`

```c
int fputs( char *str, FILE *fp );
```

### 格式化读写文件 `fscanf()` 和 `fprintf()`

`fscanf()` 和 `fprintf()` 函数与前面使用的 `scanf()` 和 `printf()` 功能相似，都是格式化读写函数，两者的区别在于 `fscanf()` 和 `fprintf()` 的读写对象不是键盘和显示器，而是磁盘文件

```c
int fscanf ( FILE *fp, char * format, ... );
int fprintf ( FILE *fp, char * format, ... );
```

如果将 `fp` 设置为 `stdin`，那么 `fscanf()` 函数将会从键盘读取数据，与 `scanf` 的作用相同；设置为 `stdout`，那么 `fprintf()` 函数将会向显示器输出内容，与 `printf` 的作用相同

### 文件定位函数 `rewind()` 和 `fseek()`

`rewind()` 用来将位置指针移动到文件开头

```
void rewind ( FILE *fp );
```

`fseek()` 用来将位置指针移动到任意位置

```
int fseek ( FILE *fp, long offset, int origin );
```

`origin` 为起始位置，也就是从何处开始计算偏移量。C语言规定的起始位置有三种，分别为文件开头、当前位置和文件末尾，每个位置都用对应的常量来表示：

起始点      |	常量名  |	常量值
------------|-----------|--------------
文件开头 	| SEEK_SET 	|      0
当前位置 	| SEEK_CUR 	|      1
文件末尾 	| SEEK_END 	|      2
