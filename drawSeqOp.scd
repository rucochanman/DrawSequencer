(
//*****load execute No.1******
s.waitForBoot({
	//////////load wav file//////////
	var wavFileName = "test"; //←change here
	var path = PathName(thisProcess.nowExecutingPath).parentPath ++ "wav/";
	var wavlen = 500;
	~buffersize = 1024;

	path = path ++ wavFileName ++ ".wav";
	(w.notNil).if{w.free};
	w = Buffer.readChannel(s, path, 0, (~buffersize/2) * wavlen, channels: 0);

	//////////fft//////////
	//clear first
	OSCdef(\send).disable;
	OSCdef(\send).enable;
	(b.notNil).if{b.free};
	(c.notNil).if{c.free};
	b = Buffer.alloc(s, ~buffersize, 1);
	c = Bus.control(s, ~buffersize);

	SynthDef(\fft, {
		var in, chain, stream, windowStarts, out;
		in = PlayBuf.ar(1, w, BufRateScale.kr(w), loop:0, doneAction:2);
		chain = FFT(b, in);
		stream = UnpackFFT(
			chain, ~buffersize, frombin:0, tobin:~buffersize/2);
		windowStarts = chain > -1;
		out = Demand.kr(windowStarts, 0, stream);
		Out.kr(c, out);
		SendTrig.kr(windowStarts,0,1);
	}).add;

	~fftArray = [];
	OSCdef(\send, { arg msg, time;
		~fftArray = ~fftArray.add(c.getnSynchronous(~buffersize));
	},'/tr', s.addr);
});
)

(
//*****execute No.2******
fork{
	Synth(\fft).waitForFree;
	"done".postln;
};
)

(
//*****execute No.3******
var pngFileName = "test"; //←change here
var len = ~fftArray.size, bins = (~buffersize/2).asInteger;
var array = Int32Array.fill(len*bins, {0});
var img = Image.color(len@bins, Color.white);
var red, green, blue, rgb, alpha=0, col;
var path = PathName(thisProcess.nowExecutingPath).parentPath;

//sorting mags, phases
var temp = [];
y = []; x = [];
~fftArray.size.do({ |i|
    temp = temp.add(~fftArray[i].clump(2).flop);
});
~fftArray.size.do({ |i|
    y = y.add(temp[i][0]);
    x = x.add(temp[i][1]);
});

//export img
path = path ++ "image/" ++ pngFileName ++ ".png";
len.do({ |i|
	var ynorm = y[i].pow(2).sqrt.normalize;
    var xnorm = (x[i]+pi)/2pi;
    var ymax = y[i].maxItem.round.asInteger;
    bins.do({ |j|
		if(j==ymax, {green=1},{green=0});
        col = Color(ynorm[j], green, xnorm[j], 1);
        array[((bins-1-j)*len)+i] = Image.colorToPixel(col);
    });
});
img.setPixels(array);
img.write(path);
img.plot;
)

(
//*****export img RGB******
var pngFileName = "test"; //←change here
var len = ~fftArray.size, bins = (~buffersize/2).asInteger;
var array = Int32Array.fill(len*bins, {0});
var img = Image.color(len@bins, Color.white);
var red, green, blue, rgb, alpha=0, col;
var path = PathName(thisProcess.nowExecutingPath).parentPath;
var paths;

//sorting mags, phases
var temp = [];
y = []; x = [];
~fftArray.size.do({ |i|
    temp = temp.add(~fftArray[i].clump(2).flop);
});
~fftArray.size.do({ |i|
    y = y.add(temp[i][0]);
    x = x.add(temp[i][1]);
});

//export img
//red
paths = path ++ "image/" ++ pngFileName ++ "_red.png";
len.do({ |i|
	var red = y[i].pow(2).sqrt.normalize;
    bins.do({ |j|
        col = Color(red[j], 0, 0, 1);
        array[((bins-1-j)*len)+i] = Image.colorToPixel(col);
    });
});
img.setPixels(array);
img.write(paths);

//green
paths = path ++ "image/" ++ pngFileName ++ "_green.png";
len.do({ |i|
    var ymax = y[i].maxItem.round.asInteger;
    bins.do({ |j|
		if(j==ymax, {green=1},{green=0});
        col = Color(0, green, 0, 1);
        array[((bins-1-j)*len)+i] = Image.colorToPixel(col);
    });
});
img.setPixels(array);
img.write(paths);

//blue
paths = path ++ "image/" ++ pngFileName ++ "_blue.png";
len.do({ |i|
    var blue = (x[i]+pi)/2pi;
    bins.do({ |j|
        col = Color(0, 0, blue[j], 1);
        array[((bins-1-j)*len)+i] = Image.colorToPixel(col);
    });
});
img.setPixels(array);
img.write(paths);
)

//////////recording audio//////////
(
//*****recording start******
var fileName = "test"; //←change here
var path = PathName(thisProcess.nowExecutingPath).parentPath;
s.record(path ++ "recordings/" ++ fileName ++ ".aiff");
)
s.stopRecording;
