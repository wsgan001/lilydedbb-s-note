# OpenGL 基础

### 基于 macOS Xcode

创建项目：

![image](../images/OpenGL_Xcode_0.png)

添加 `GLUT.framework` 和 `OpenGL.framework` 两个框架：

![image](../images/OpenGL_Xcode_1.png)

![image](../images/OpenGL_Xcode_2.png)


### 基于 Windows Visual Studio


### 第一个 OpenGL 程序

```c
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <GLUT/glut.h>

void init (void) {
    glClearColor(1.0, 1.0, 1.0, 0.0);
    glMatrixMode(GL_PROJECTION); // 使用正投影将世界坐标系映射到屏幕上
    gluOrtho2D(0.0, 200.0, 0.0, 150.0); // x 坐标从 0.0 到 200.0; y 坐标从 0.0 到 150.0（只有该范围内的无题才会被显示出来）
}

void lineSegment (void) {

    glClear(GL_COLOR_BUFFER_BIT); // clear display window

    glColor3f(0.0, 0.4, 0.2); // 设置线条颜色
    glBegin(GL_LINE);
        glVertex2i(180, 15);
        glVertex2i(10, 145);
    glEnd();

    glFlush();
}

int main (int argc, char** argv) {

    glutInit(&argc, argv);

    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);
    glutInitWindowPosition(50, 100);
    glutInitWindowSize(400, 300);
    glutCreateWindow("An Example OpenGL Program");

    init();
    glutDisplayFunc(lineSegment);
    glutMainLoop();

    return 0;
}
```