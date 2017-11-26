# BMP图像信息隐藏

`define.h` 文件：

```c
//
//  define.h
//  encrypt_by_bmp
//
//  Created by 大宝宝 on 2017/6/25.
//  Copyright © 2017年 lilydedbb. All rights reserved.
//

#ifndef define_h
#define define_h

typedef unsigned short WORD; // 2字节
typedef unsigned int DWORD; // 4字节
typedef unsigned char BYTE; // 1字节

// 文件头
typedef struct BMP_FILE_HEADER {
    WORD type; // 文件类型
    DWORD size; // 文件大小,单位为Byte
    WORD reserved1; // 保留字1
    WORD reserved2; // 保留字2
    DWORD offBits; // 位图数据起始位置,用相对于文件头的偏移量表示,单位为Byte
} BMP_FILE_HEADER;

// 信息头
typedef struct BMP_INFO_HEADER {
    DWORD size; // 信息头大小
    int width; // 位图宽度,单位为像素
    int height; // 位图高度,单位为像素
    WORD planes; // 目标设备的级别,固定取值1
    WORD bitCount; // 表示每个像素所用的bit数
    DWORD compression; // 压缩类型
    DWORD sizeImage; // 位图大小,单位为字节
    int xPelsPerMeter; // 水平分辨率
    int yPelsPerMeter; // 垂直分辨率
    DWORD colorUsed; // 实际使用的颜色表中的颜色数量
    DWORD colorImportant; // 重要的颜色数目
} BMP_INFO_HEADER;

// 调色板
typedef struct RGBQUAD{
    BYTE blue; // 蓝色的亮度
    BYTE green; // 绿色的亮度
    BYTE red; // 红色的亮度
    BYTE reserved; // 保留字段,取值0
}RGBQUAD;

// RGB三色
typedef struct RGB{
    BYTE blue;
    BYTE green;
    BYTE red;
}RGB;

#endif /* define_h */
```

`encrypt.c`:

```c
//
//  encrypt.c
//  encrypt_by_bmp
//
//  Created by 大宝宝 on 2017/6/25.
//  Copyright © 2017年 lilydedbb. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>

// stat 系统函数需要的头文件
#include <sys/stat.h>
#include <unistd.h>

#include "define.h"

// 获取文件大小
int getFileSizeSystemCall (char* strFileName) {
    struct stat temp;
    stat(strFileName, &temp);
    return (int)temp.st_size;
}

int main (int argc, const char * argv[]) {
    
    // 创建文件头,信息头结构体变量
    BMP_FILE_HEADER fileHeader;
    BMP_INFO_HEADER infoHeader;
    
    // 打开载体图像文件,读取文件头和信息头.打开隐秘图像文件
    FILE *file = fopen("lily.bmp", "rb");
    FILE *newFile = fopen("lily_with_encrypted_message.bmp", "wbx");
    fread(&fileHeader, 14, 1, file);
    fread(&infoHeader, 40, 1, file);

    // 读取秘密信息文件"define.h"
    int infoSize = getFileSizeSystemCall("define.h");
    printf("info size: %d\n", infoSize);
    BYTE *info = (BYTE *) malloc(infoSize);
    FILE *infoFile = fopen("define.h", "rb");
    fread(info, infoSize, 1, infoFile);
    
    // 读取24位真彩图像像素信息
    BYTE *img = (BYTE *) malloc(infoHeader.sizeImage);
    fread(img, infoHeader.sizeImage, 1, file);

    // 打印基本信息
    printf("图片大小(宽x高): %d x %d\n", infoHeader.width, infoHeader.height);
    printf("可以隐藏%d字节信息\n", infoHeader.sizeImage / 8);

    // LSB算法实现,把隐秘信息的每一字节8bit按照低字节到高字节的顺序隐藏到像素信息的每8Byte中的最低位
    BYTE tmp = 0x00;
    for (int i = 0; i < infoSize; i++) {
        for (int j = 0; j < 8; j++) {
            tmp = info[i] & 0x01;
            if(tmp) img[i * 8 + j] = img[i * 8 + j] | 0x01;
            else img[i * 8 + j] = img[i * 8 + j] & 0xfe;
            info[i] = info[i] >> 1;
        }
    }
    
    // 将修改后的二进制数据写入到隐秘图像文件中
    fwrite(&fileHeader, 14, 1, newFile);
    fwrite(&infoHeader, 40, 1, newFile);
    fwrite(img, infoHeader.sizeImage, 1, newFile);

    // 关闭文件
    fclose(file);
    fclose(newFile);
    
    return 0;
}
```

`extract.c`:

```c
//
//  extract.c
//  encrypt_by_bmp
//
//  Created by 大宝宝 on 2017/6/25.
//  Copyright © 2017年 lilydedbb. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include "define.h"

int main(){

	// 创建文件头,信息头结构体变量
	BMP_FILE_HEADER fileHeader;
	BMP_INFO_HEADER infoHeader;

	// 读取隐秘图像文件,创建秘密信息文件
	FILE *file = fopen("lily_with_encrypted_message.bmp", "rb");
	FILE *extractFile = fopen("extracted_message.txt", "wbx");
	BYTE *info = (BYTE *) malloc(672);

	// 读取文件头,信息头
	fread(&fileHeader, 14, 1, file);
	fread(&infoHeader, 40, 1, file);
	
	// 读取24位真彩图像的像素信息
	BYTE *img = (BYTE *) malloc(infoHeader.sizeImage);
	fread(img, infoHeader.sizeImage, 1, file);

	// 打印基本信息
	printf("图片大小(宽x高):%d x %d\n", infoHeader.width, infoHeader.height);

	// 信息提取部分，根据秘密信息的长度，依次读取隐秘图像像素信息的最低bit，拼接成Byte.
	BYTE tmp = 0x00, ttmp = 0x00;
	for(int i = 0; i < 672; i++){
		tmp = 0x00;
		for(int j = 0; j < 8; j++){
			ttmp = img[i * 8 + j] & 0x01;
			ttmp = ttmp << j;
			tmp += ttmp;
		}
		info[i] = tmp;
	}
	
	//将提取的信息写入秘密信息文件中
	fwrite(info, 672, 1, extractFile);

	//关闭文件
	fclose(file);
	fclose(extractFile);

	return 0;
}
```

生成二进制文件后执行：

```
$ gcc -o extract extract.c 
$ gcc -o encrypt encrypt.c 
$ ./encrypt 
info size: 1507
图片大小(宽x高): 128 x 128
可以隐藏6144字节信息
$ ./extract 
图片大小(宽x高):128 x 128
```