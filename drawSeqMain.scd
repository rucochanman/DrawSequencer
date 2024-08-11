(
s.waitForBoot({
    f = {
		//sizes
		var bins=512, len=500; //fft window size		
		var cw=len/16, m=(len-(13*cw))/6, hm=cw*2; //margin
		var gx=0, gy=0, flag=false; //pixel status
		//menu
		var cols, colw, range, tex1, tex2, go, select, menu=0;
		var p = PathName(thisProcess.nowExecutingPath).parentPath, path;
		var col = Color.black, cleft=0, cright=0;
		//functions
		var setPixels, menuAction, reDraw;
		var copyExe, delExe, moveExe, loadExe, saveExe, addExe, pstExe;
		var copyPixels=[], copyPhases=[], copyMax=[];

		//global
		~spos=0; ~linepos=0;
		~pixels=Array.fill([len,bins],{0});
		~phases=Array.fill([len,bins],{0});
		~max=Array.fill(len,{10});

		//////////make window//////////
		w = Window("fft sequencer", Rect(100, 200, len+(m*2), bins+hm+m))
		.acceptsMouseOver_(true)
		.background_(col);

		range = UserView(w, Rect(m, hm, len, bins))
		.background_(Color.white)
		.drawFunc_{
			Pen.fillColor = Color.magenta(1, 0.3);
			Pen.addRect(Rect(cleft-~spos, 0, cright-cleft, bins));
			Pen.fill;
		};

		//////////draw window//////////
		~pix = UserView(w, Rect(m, hm, len, bins))
		.clearOnRefresh_(false)
		.mouseDownAction_({|v,x,y| setPixels.value(x,y)})
		.mouseMoveAction_({|v,x,y|
			setPixels.value(x,y);
			(menu==0).if{menuAction.value(x,y)}})
		.mouseOverAction_({|v,x,y| (menu==0).if{menuAction.value(x,y)}})
		.drawFunc_{
			//draw point
			(flag==false).if{
				Pen.fillColor = Color.grey(1.0 - ~pixels[gx][gy], 1);
				Pen.addRect(Rect(gx-~spos, (bins-1)-gy, 1, 1));
				Pen.fill;
			};
			//redraw all
			(flag).if{
				//right clip
				Pen.fillColor = Color.grey(0.9);
				Pen.addRect(Rect(~pixels.size-~spos, 0,
					len-(~pixels.size-~spos), bins));
				Pen.fill;
				//redraw pixels
				~pixels.do({ |bloc, x|
					bloc.do({ |p, y|
						var a = if(p>0, {1},{0});
						Pen.fillColor = Color.grey(1.0-p, a);
						Pen.addRect(Rect(x-~spos, (bins-1)-y, 1, 1));
						Pen.fill;
					});
				});
				flag = false;
			};
		};

		//////////set array//////////
		setPixels = { |x,y|
			gx = (x+~spos).clip(0, ~pixels.size-1);
			gy = ((bins-1)-y).clip(0, bins-1);
			~pixels[gx][gy] = 1.0 - (col.red);
			~pix.refresh;
		};
		~pix.action = {~pix.refresh};

		reDraw = {
			flag = true;
			~pix.clearDrawing;
			~pix.refresh;
		};

		//////////draw line//////////
		~line = UserView(w, Rect(m, hm, 1, bins)).background_(Color.green);

		//////////control menu//////////
		//color picker
		colw = UserView(w, Rect(m,cw/2,cw,cw))
		.background_(Color.white)
		.drawFunc_{
			Pen.fillColor = col;
			Pen.addRect(Rect(1, 1, cw-2, cw-2));
			Pen.fill;
		};
		cols = Slider(w, Rect((m*2)+cw,cw/2,cw*4,cw))
		.background_(Color.grey)
		.action_({
			col = Color.grey(cols.value);
			colw.refresh;
		});

		//text field
		tex1 = TextField(w, Rect((m*3)+(cw*5), cw/2, cw*2, cw))
		.action_({ |field|
			menuAction.value(tex1.value, tex2.value);
		});
		tex2 = TextField(w, Rect((m*4)+(cw*7), cw/2, cw*2, cw))
		.action_({ |field|
			menuAction.value(tex1.value, tex2.value);
		});

		//menu select
		select = PopUpMenu(w, Rect((m*5)+(cw*9),cw/2,cw*2,cw))
		.items_(["xy", "copy", "del", "move", "load", "save", "add", "pst"])
		.action_({ arg item;
			menu = item.value;
			menuAction.value(0, 0);
			cleft=0; cright=0;
			range.refresh;
		});

		//go button
		go = Button(w, Rect((m*6)+(cw*11), cw/2, cw, cw))
		.string_("GO")
		.action_({
			switch(menu,
                1, { copyExe.value },
                2, { delExe.value },
                3, { moveExe.value },
                4, { loadExe.value },
                5, { saveExe.value },
                6, { addExe.value },
                7, { pstExe.value }
			);
		});

		//play-stop button
		~pbtn = Button(w, Rect((m*7)+(cw*12), cw/2, cw, cw))
		.states_([["▶︎", Color.white, Color.blue],
			["■", Color.white, Color.black]]
		)
		.action_({ |stat|
			if(stat.value==1,{
				~play.value;
			},{
				~stop.value;
			});
		});

		menuAction = { |val1, val2|
			switch(menu,
				//xy_display
				0, {
					var x, y;
					x = val1.clip(0, ~pixels.size);
					y = (bins-1)-val2;
					tex1.string_(x); tex2.string_(y);
					tex1.background_(Color.white);
					tex2.background_(Color.white);
				},
				//copy
				1, {
					var left = val1.asInteger.clip(0, ~pixels.size);
					var right = val2.asInteger.clip(0, ~pixels.size);
					tex2.background_(Color.white);
					tex1.string_(left); tex2.string_(right);
					(right > left).if{
						cleft = left; cright = right;
						range.refresh;
					};
				},
				//delete
				2, {
					var left = val1.asInteger.clip(0, ~pixels.size);
					var right = val2.asInteger.clip(0, ~pixels.size);
					tex2.background_(Color.white);
					tex1.string_(left); tex2.string_(right);
					(right > left).if{
						cleft = left; cright = right;
						range.refresh;
					};
				},
				//move
				3, {
					var left = val1.asInteger.clip(0, ~pixels.size);
					tex1.string_(left); tex2.string_("");
					tex2.background_(Color.grey(0.8));
				},
				//load
				4, {
					cleft = val1.asInteger;
					cright = val2.asInteger.clip(0, ~pixels.size);
					tex2.background_(Color.white);
					path = p ++ "image/" ++ cleft ++ ".png";
					tex1.string_(cleft); tex2.string_(cright);
				},
				//save
				5, {
					cleft = val1.asInteger;
					path = p ++ "image/" ++ cleft ++ ".png";
					tex1.string_(cleft); tex2.string_("");
					tex2.background_(Color.grey(0.8));
				},
				//add
				6, {
					cleft = val1.asInteger;
					tex1.string_(cleft); tex2.string_("");
					tex2.background_(Color.grey(0.8));
				},
				//paste
				7, {
					cleft = val1.asInteger.clip(0, ~pixels.size);
					tex1.string_(cleft); tex2.string_("");
					tex2.background_(Color.grey(0.8));
				}
			);
		};

		//execution when GO pressed
		copyExe = {
			//make blank array
			var copyArray = (cleft..cright);
			copyPixels = Array.fill([copyArray.size,bins],{0});
			copyPhases = Array.fill([copyArray.size,bins],{0});
			copyMax = Array.fill(copyArray.size,{10});
			//set array
			copyArray.do({|i|
				~pixels[i].do({|item, j|
					copyPixels[i][j] = item;
				});
				~phases[i].do({|item, j|
					copyPhases[i][j] = item;
				});
				copyMax[i] = ~max[i];
			});
			reDraw.value;
			~restart.value;
		};

		delExe = {
			(cright-cleft).do({
				~pixels.removeAt(cleft);
				~phases.removeAt(cleft);
                ~max.removeAt(cleft);
			});
			reDraw.value;
			~restart.value;
		};

		moveExe = {
			~spos = tex1.value.asInteger;
			reDraw.value;
			~restart.value;
		};

		loadExe = {
			var img = Image.new(path);
			var w = img.width + cright;
			//add buffer
			(w > ~pixels.size).if{
				var diff = w - ~pixels.size;
				diff.do({
					~pixels = ~pixels.add(Array.fill(bins,{0}));
					~phases = ~phases.add(Array.fill(bins,{0}));
					~max = ~max.add(0);
				});
			};
			//set value
			img.width.do({ |x|
				img.height.do({ |y|
					var px = img.getPixel(x, (bins-1)-y);
					var mag = Image.pixelToColor(px).red;
					var pha = Image.pixelToColor(px).blue;    
					var max = Image.pixelToColor(px).green;
					mag = (mag + ~pixels[x+cright][y]).clip(0, 1.0);
					~pixels[x+cright][y] = mag;
					~phases[x+cright][y] = (pha*2pi)-pi;
					(max==1).if{ ~max[x+cright] = y };
				});
			});
			reDraw.value;
			~restart.value;
		};

		saveExe = {
			var array = Int32Array.fill(~pixels.size*bins, {0});
			var img = Image.color(~pixels.size@bins, Color.white);
			var c, r, g, b, max;
			~pixels.size.do({|iy|
				bins.do({|ix|
					r = ~pixels[iy][ix];
					b = (~phases[iy][ix]+pi)/2pi;
					if(ix==~max[iy], {g=1},{g=0});
					c = Color(r,g,b,1.0);
					array[((bins-1-ix)*~pixels.size)+iy] = Image.colorToPixel(c);
				});
			});
			img.setPixels(array);
			img.write(path);
			~restart.value;
		};

		addExe = {
			(cleft).do({|i|
				~pixels = ~pixels.add(Array.fill(bins,{0}));
				~phases = ~phases.add(Array.fill(bins,{0}));
				~max = ~max.add(10);
			});
			reDraw.value;
			~restart.value;
		};

		pstExe = {
			//add buffer
			var w = copyPixels.size + cleft;
			(w > ~pixels.size).if{
				var diff = w - ~pixels.size;
				diff.do({
					~pixels = ~pixels.add(Array.fill(bins,{0}));          
					~phases = ~phases.add(Array.fill(bins,{0}));                    
					~max = ~max.add(0);
				});
			};
			//paste data
			copyPixels.do({|bin, i|
				bin.do({|item, j|
					~pixels[i+cleft][j] =
					(~pixels[i+cleft][j] + item).clip(0.0, 1.0);
				});
			});
			copyPhases.do({|bin, i|
				bin.do({|item, j|
					~phases[i+cleft][j] =
					(~phases[i+cleft][j] + item).clip(-2pi, 2pi);
				});
			});
			copyMax.do({|item, i|
				~max[i+cleft] = (~max[i+cleft] + item).clip(0, 512);
			});
			reDraw.value;
			~restart.value;
		};

		//display window
		w.onClose = { ~stop.value };
		w.front;
	};

	//////////play sound//////////
	~play = {
		fork{
			var bins=512, len=500;
			var cw=len/16, m=(len-(13*cw))/6, hm=cw*2; //margin
			SynthDef(\ifft_draw, {
				var mags = \mag.kr(1!bins);
				var phases = \phase.kr(1!bins);
				var chain, sig, count, windowStarts;
				chain = FFT(LocalBuf(1024), FSinOsc.ar);
				windowStarts = chain > -1;
				count = Stepper.kr(windowStarts, 0, 0, ~pixels.size-1);
				chain = PackFFT(
					chain, bins, [mags, phases].flop.flatten, 0, bins, 1);
				sig = IFFT(chain);
				Out.ar(0, sig.clip(-1, 1).dup);
				SendTrig.kr(windowStarts, 0, count);
			}).add;

			OSCdef(\mf_set,{ arg msg;
				var count = msg[3].asInteger;
				var mag = ~pixels[count] * ~max[count];
				~linepos = count;
				h.set(\mag, mag, \phase, ~phases[count]);
			},'/tr', s.addr);

			//set routine
			r = Routine({ arg appClockTime;
				loop({
					var pos = (m + ~linepos - ~spos).clip(m, m+len);
					~line.bounds = Rect(pos, hm, 1, bins);
					0.1.wait;
				})
			});
			//play start
			0.1.wait;
			AppClock.play(r);
			h = Synth(\ifft_draw);
			OSCdef(\mf_set).enable;
		};
	};

	~stop = {
		if(h.isNil, {s.freeAll}, {h.free});
		AppClock.stop(r);
		OSCdef(\mf_set).disable;
	};

	~restart = {
		fork{
			~stop.value;
			0.1.wait;
			~play.value;
		};
		~pbtn.value = 1;
	};

	//////////execute///////////
	f.value;

});
)
