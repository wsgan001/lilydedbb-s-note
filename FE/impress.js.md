# ```impress.js```

> ```impress.js``` is a presentation tool based on the power of CSS3 transforms and transitions in modern browsers and inspired by the idea behind [prezi.com](https://prezi.com/).



### 设置回退消息

使用```impress.js```为了有一个好的兼容，应当设置好回退消息，以在浏览器不支持```CSS3```的新特性的时候，显示一个提示消息。

官方demo的提示消息如下：
```html
<div class="fallback-message">
    <p>Your browser <b>doesn't support the features required</b> by impress.js, so you are presented with a simplified version of this presentation.</p>
    <p>For the best experience please use the latest <b>Chrome</b>, <b>Safari</b> or <b>Firefox</b> browser.</p>
</div>
```
```css
.fallback-message {
    font-family: sans-serif;
    line-height: 1.3;

    width: 780px;
    padding: 10px 10px 0;
    margin: 20px auto;

    border: 1px solid #E4C652;
    border-radius: 10px;
    background: #EEDC94;
}

.fallback-message p {
    margin-bottom: 10px;
}

.impress-supported .fallback-message {
    display: none;
}
```


```html
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=1024" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <title>impress.js</title>
    <meta name="description" content="powered by impress.js" />
    <meta name="author" content="dbb" />
    <link href="css/impress-demo.css" rel="stylesheet" />
    <link rel="shortcut icon" href="favicon.png" />
    <link rel="apple-touch-icon" href="apple-touch-icon.png" />
</head>
<body class="impress-not-supported">
    <div class="fallback-message">
        <p>Your browser <b>doesn't support the features required</b> by impress.js, so you are presented with a simplified version of this presentation.</p>
        <p>For the best experience please use the latest <b>Chrome</b>, <b>Safari</b> or <b>Firefox</b> browser.</p>
    </div>
    <div id="impress">
        <!--1-->
        <div id="first" class="step slide" data-x="-1200" data-y="-1400" data-rotate="-30">
            <h1>物理光学大作业</h1>
            <h3><b>谢亮 邹凯峰</b></h3>
            <h3>范立文 李金泽 战庶 余涵</h3>
        </div>
        <!--2-->
        <div id="1st" class="step slide" data-x="0" data-y="-1700" data-rotate="0">
            <h2>干涉1</h2>
            <p>设波长为632nm的单色平面波垂直照射如图的双缝干涉装置，双缝间距d=0.4mm，单缝到双缝的距离l=5cm，观察屏到双缝距离D=2m</p>
            <p>试计算探讨当单缝宽度逐步增大时，观察屏上干涉条纹对比度的变化，并求出其临界宽度。要求用动画显示单缝增宽时干涉条纹的变化。</p>
        </div>
        <!--3-->
        <div class="step slide image-slide" data-x="1200" data-y="-1400" data-rotate="30">
            <img src="./images/1.png" height="100%" width="100%">
        </div>
        <!--4-->
        <div id="1-code" class="step code" data-x="400" data-y="700" data-scale="4">
            <pre>
clear
lim = 0.005;
D = 2;          % 孔到光屏的距离
wlen = 632e-9;  % 波长
d = 0.4e-3;     % 两孔距离
l = 0.05;       % 单缝到双缝的距离

%-------------------改变缝宽，计算相对光强-------------------
for j = 1:78
    %-------------------参数计算-------------------
    bc = 0.000001+j*0.000001;                       % 光源宽度
    b = d / l;                                      % 相干孔径角
    dx = 0.00001;                                   % x微元
    x = -lim:dx:lim;                                % 条纹距中心距离
    r1 = sqrt((x - d/2).^2 + D.^2);                 % 光程1
    r2 = sqrt((x + d/2).^2 + D.^2);                 % 光程2
    phi = 2 * pi / wlen * (r2 - r1);                % 光程差对应的相位差
    I = 2 * bc + 2 * (wlen / (pi * b)) * sin(bc * (pi * b / wlen)) * cos(phi);    % 光强
    %-------------------显示-------------------
    fs = 10;                                        % 字符大小
    %-------------------上方曲线-------------------
    subplot(2, 1, 1);
    plot(x, I);                                     % x与i的关系图
    grid on                                         % 打开网格
    axis([-0.005, 0.005, 0e-5, 30e-5])
    title('光强的干涉强度分布', 'fontsize', fs)
    xlabel('x/m', 'fontsize', fs)
    ylabel('相对强度', 'fontsize', fs)
    %-------------------下方光强-------------------
    subplot(2, 1, 2)
    r = linspace(0, 1, 64)';
    g = zeros(size(r));
    b = zeros(size(r));
    colormap([r g b])                               % 64 * 3的colormap
    image(I * (64 / 1.580e-4))
    axis([0, 1000, 0.5, 1.5])
    title('光的干涉条纹', 'fontsize', fs)
    text(0.8, 1.65, '缝宽b=');
    text(100, 1.65, num2str(bc))
    M(:,j) = getframe;

end
            </pre>
        </div>
        <!--5-->
        <div id="1-1" class="step slide image-slide" data-x="2825" data-y="825" data-z="-30000" data-rotate="360" data-scale="1">
            <img src="./images/1-1.png" height="100%" width="100%">
        </div>
        <!--6-->
        <div id="1-2" class="step slide image-slide" data-x="4225" data-y="1425" data-z="-30000" data-rotate="420" data-scale="1">
            <img src="./images/1-2.png" height="100%" width="100%">
        </div>
        <!--7-->
        <div id="1-3" class="step slide image-slide" data-x="4225" data-y="2825" data-z="-30000" data-rotate="480" data-scale="1">
            <img src="./images/1-3.png" height="100%" width="100%">
        </div>
        <!--8-->
        <div id="1-4" class="step slide image-slide" data-x="2825" data-y="3625" data-z="-30000" data-rotate="540" data-scale="1">
            <img src="./images/1-4.png" height="100%" width="100%">
        </div>
        <!--9-->
        <div id="1-5" class="step slide image-slide" data-x="1425" data-y="2825" data-z="-30000" data-rotate="600" data-scale="1">
            <img src="./images/1-5.png" height="100%" width="100%">
        </div>
        <!--10-->
        <div id="1-6" class="step slide image-slide" data-x="1425" data-y="1425" data-z="-30000" data-rotate="660" data-scale="1">
            <img src="./images/1-6.png" height="100%" width="100%">
        </div>
        <!--11-->
        <div id="1-video" class="step slide video-slide" data-x="2825" data-y="2225" data-z="-30000" data-rotate="0" data-scale="1">
            <video src="./videos/1.mov" autoplay="autoplay" controls="controls" width="100%" height="100%"></video>
        </div>
        <!--12-->
        <div id="2nd" class="step" data-x="4425" data-y="1425" data-rotate="0" data-scale="6">
            <h2>偏振1</h2>
        </div>
        <!--13-->
        <div class="step" data-x="4425" data-y="1425" data-rotate-x="90" data-rotate-y="0" data-rotate-z="0" data-scale="5">
            <p>题目二：假设一波长为632nm的线偏振光垂直穿过1/4波片(厚度2mm)，试计算当线偏振光E振动方向与波片快轴夹30度和45度角时，输出光的偏振态。并用三维动画显示E穿透波片的演变过程</p>
        </div>
        <!--14-->
        <div class="step"  data-x="4425" data-y="1425" data-rotate="0" data-scale="5">
            <b>由于光速太快，,估算要经过近四千个周期，线偏振光才会完全转换为圆偏振光，真实数据不好模拟，为了更好地显示出波片内部的情况，我们小组用在matlab上画了十个周期描述转换过程。
            真实数据截图</b>
        </div>
        <!--15-->
        <div id="2-code" class="step code" data-x="3500" data-y="-850" data-z="40000" data-rotate="0" data-scale="6">
            <pre>
clear;
c = 0.01;               % 光速
w = 0.01 * pi * 2;      % 波长
a = 1;                  % 幅度
angle = pi / 6;         % 与快轴夹脚

for j = 1:3000
    %------------------参数计算------------------
    phi = -j / 10;                              % 运动相位
    i = 1:1:2000;
    y = c * i;                                  % y轴为运动方向
    xo = linspace(0, 0, 2000);                  % o光
    zo = a * cos(angle) * cos(i * w + phi);     % o光
    p = [linspace(0, 0, 500) linspace(1, 1000, 1000) / 1000 * (pi / 2) linspace(pi/2, pi/2, 500)];
    xe = a * sin(angle) * cos(i * w + phi - p); % e光
    ze = linspace(0, 0, 2000);                  % e光
    x = xo + xe;                                % 合光矢
    z = zo + ze;                                % 合光矢
    %------------------显示------------------
    plot3(x, y, z, '-k');
    axis([-1, 1, -2, 22, -1, 1]);
    grid on;
    M(:,j) = getframe;
end
movie(M, 1, 1);
            </pre>
        </div>
        <!--16-->
        <div id="2-1" class="step slide image-slide" data-x="2825" data-y="825" data-z="60000" data-rotate="360" data-scale="1">
            <img src="./images/2-1.png" height="100%" width="100%">
        </div>
        <!--17-->
        <div id="2-2" class="step slide image-slide" data-x="4225" data-y="1425" data-z="60000" data-rotate="420" data-scale="1">
            <img src="./images/2-2.png" height="100%" width="100%">
        </div>
        <!--18-->
        <div id="2-3" class="step slide image-slide" data-x="4225" data-y="2825" data-z="60000" data-rotate="480" data-scale="1">
            <img src="./images/2-3.png" height="100%" width="100%">
        </div>
        <!--19-->
        <div id="2-4" class="step slide image-slide" data-x="2825" data-y="3625" data-z="60000" data-rotate="540" data-scale="1">
            <img src="./images/2-4.png" height="100%" width="100%">
        </div>
        <!--20-->
        <div id="2-5" class="step slide image-slide" data-x="1425" data-y="2825" data-z="60000" data-rotate="600" data-scale="1">
            <img src="./images/2-5.png" height="100%" width="100%">
        </div>
        <!--21-->
        <div id="2-6" class="step slide image-slide" data-x="1425" data-y="1425" data-z="60000" data-rotate="660" data-scale="1">
            <img src="./images/2-6.png" height="100%" width="100%">
        </div>
        <!--22-->
        <div id="2-video" class="step slide image-slide" data-x="2925" data-y="2100" data-z="60000" data-rotate="660" data-scale="1">
            <video src="./videos/2.mov" autoplay="autoplay" controls="controls" width="100%" height="100%"></video>
        </div>
        <!--23-->
        <div id="last" class="step" data-x="1425" data-y="1425" data-z="100000" data-rotate="660" data-scale="1">
            <h1>Powered by Matlab & JavaScript</h1>
            <h6>copyright © 2016 dbb. All Rights Reserved</h6>
        </div>
    </div>
    <script>
    if ("ontouchstart" in document.documentElement) {
        document.querySelector(".hint").innerHTML = "<p>Tap on the left or right to navigate</p>";
    }
    </script>
    <script src="js/impress.js"></script>
    <script>impress().init();</script>
</body>
</html>
```
