# Shell 控制流程


## if ... else

```bash
if [ expression ]
then
   Statement(s) to be executed if expression is true
fi
```


## if ... else ... fi

```bash
if [ expression ]
then
   Statement(s) to be executed if expression is true
else
   Statement(s) to be executed if expression is not true
fi
```


## if ... elif ... fi

```bash
if [ expression 1 ]
then
   Statement(s) to be executed if expression 1 is true
elif [ expression 2 ]
then
   Statement(s) to be executed if expression 2 is true
elif [ expression 3 ]
then
   Statement(s) to be executed if expression 3 is true
else
   Statement(s) to be executed if no expression is true
fi
```


## case esac

```bash
case 值 in
模式1)
    command1
    command2
    command3
    ;;
模式2）
    command1
    command2
    command3
    ;;
*)
    command1
    command2
    command3
    ;;
esac
```


## for 循环

```bash
for 变量 in 列表
do
    command1
    command2
    ...
    commandN
done
```

## while 循环

```bash
while command
do
   Statement(s) to be executed if command is true
done
```

## until 循环

```bash
until command
do
   Statement(s) to be executed until command is true
done
```