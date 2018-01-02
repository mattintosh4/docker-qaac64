```
$ ./qaac_builder.sh
$ docker build -t qaac64 .
```

```
$ docker run --rm -v $PWD:/mnt qaac64 wine qaac64.exe --raw --raw-format s16be --raw-channels 2 --rate 48000 cdda.bin
```
