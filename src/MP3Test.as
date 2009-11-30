/*
MP3 Player for Listening Tests

Copyright (C) 2009 Matt Bury
Website: http://matbury.com/
Contact: matbury@gmail.com

Version: 20091117

This program is free software: You can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public Licence along with this program. If not, see <http://www.gnu.org/licenses/>.
*/
package {
	
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.*;
	import flash.text.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.filters.DropShadowFilter;
	
	public class MP3Test extends Sprite {
		
		// User feedback messages. Edit these to change language.
		// TODO: Include parameter to XML file to change these to
		// provide multi-language support default should be English.
		private var _noURL:String = "Please provide a URL to the MP3 file to play.";
		private var _loading:String = "Loading audio... ";
		private var _loadingComplete:String = "Complete. Press play to start.";
		private var _waiting:String = "Waiting for MP3 tag info... ";
		private var _finished:String = "The recording has finished.";
		private var _sorry:String = "Sorry, there was a problem with the audio. Please try again or contact admin.";
		// --------------------------------------------------------------------------------------------------------
		private var _font:String = "Trebuchet MS"; // This determines all the display text fonts
		private var _url:String = ""; // MP3 file to load and play
		private var _urlPresent:Boolean = true;
		private var _pb:PlayButton;
		private var _sx:int = 0; // .x position of the scubber bar
		private var _sb:Scrubber; // graphic play back display
		private var _dsf:DropShadowFilter;
		private var _t:TextField; // time elapsed text display
		private var _tr:TextField; // time remaining text display
		private var _id3:TextField; // MP3 ID3 tags text display
		private var _s:Sound; // sound object (contains the loaded MP3 file)
		private var _sc:SoundChannel; // controls playback of sound object
		private var _sl:Number; // the total length of the loaded sound in milliseconds
		private var _timesToPlay:int = 1; // the number of times to play the MP3
		private var _playCount:int = 0; // the number of times the MP3 has been played
		private var _waitToPlay:Boolean = false; // wait for MP3 download to finish before playing
		private var _showPlay:Boolean = false; // show play button and wait to play
		private var _loaded:Boolean = false; // MP3 file has finished loading
		private var _playing:Boolean = false; // MP3 file is playing
		private var _gotId3:Boolean = false; // MP3 file's ID3 tags can be accessed
		private var _cmenu:CMenu; // Context menu - please do not change or remove
		
		public function MP3Test() {
			stage.scaleMode = StageScaleMode.NO_SCALE; // Do not scale the display to fit the Flash Player window
			stage.align = StageAlign.TOP_LEFT; // Anchor the display to the top left of the Flash Player window
			init();
		}
		
		private function init():void {
			_dsf = new DropShadowFilter(2,45,0,1,2,2); // Create shadow for player graphics
			initCMenu();
			initTextDisplay(); // Create text display
			initParameters(); // Assign parameters from FlashVars
			if(_urlPresent) {
				initSound(); // Start loading sound
			} else {
				_t.text = _noURL;
				_id3.text = "";
			}
			if(_showPlay) {
				initPlayButton();
			}
			initProgressBar();
		}
		
		// Create custom context menu (right-click on Flash Player) which shows author, GPL licence and copyright
		// Please do not remove or change this!
		private function initCMenu():void {
			var cmenu:CMenu = new CMenu();
			addChild(cmenu);
			cmenu.addCMenu();
		}
		
		// ----------------------------------------- PARAMETERS ----------------------------------------- //
		
		// Get player configuration settings
		private function initParameters():void {
			// Report error if mp3url hasn't been set
			if(this.root.loaderInfo.parameters.mp3url) {
				_url = this.root.loaderInfo.parameters.mp3url;
				_urlPresent = true;
			}
			// Set timesToPlay optional parameter. uint defaults to 0 so check that it exists first
			if(this.root.loaderInfo.parameters.timesToPlay) {
				_timesToPlay = uint(this.root.loaderInfo.parameters.timesToPlay); // don't accept decimals or negatives
			} else {
				_timesToPlay = 1; // Set default to 1
			}
			// Set waitToPlay optional parameter. Anything but waitToPlay=true returns false.
			if(this.root.loaderInfo.parameters.waitToPlay) {
				if(this.root.loaderInfo.parameters.waitToPlay == "true") {
					_waitToPlay = true;
				}
			}
			// Set showPlay optional parameter. Anything but showPlay=true returns false.
			if(this.root.loaderInfo.parameters.showPlay) {
				if(this.root.loaderInfo.parameters.showPlay == "true") {
					_showPlay = true;
				}
			}
			//_urlPresent = true; // For testing in Flash IDE
			//_showPlay = false; // For testing in Flash IDE
			//_waitToPlay = false; // For testing in Flash IDE
		}
		
		// ----------------------------------------- DISPLAY ----------------------------------------- /
		
		// Create the text play back display fields
		private function initTextDisplay():void {
			var f:TextFormat = new TextFormat();
			f.font = "Trebuchet MS";
			f.size = 15;
			f.bold = true;
			// time elapsed display
			_t = new TextField();
			_t.autoSize = TextFieldAutoSize.LEFT;
			_t.defaultTextFormat = f;
			_t.x = 2;
			_t.y = 20;
			_t.text = _loading;
			addChild(_t);
			// time remaining display
			_tr = new TextField();
			_tr.autoSize = TextFieldAutoSize.RIGHT;
			_tr.defaultTextFormat = f;
			_tr.x = stage.stageWidth - 10;
			_tr.y = 20;
			_tr.text = "";
			addChild(_tr);
			// ID3 tag info display
			_id3 = new TextField();
			_id3.autoSize = TextFieldAutoSize.LEFT;
			_id3.x = 2;
			_id3.y = _t.y + _t.height;
			_id3.defaultTextFormat = f;
			_id3.text = _waiting;
			addChild(_id3);
		}
		
		// Create playback button (optional, i.e. showPlay=true)
		private function initPlayButton():void {
			_pb = new PlayButton(); // graphic play button is in FLA library
			_pb.mouseChildren = false;
			_pb.x = _pb.width * 0.5;
			_pb.y = _pb.height * 0.5;
			_pb.filters = [_dsf];
			_sx = _pb.x + _pb.width;
			addChild(_pb);
		}
		
		// When playback button is pressed
		private function playDown(event:MouseEvent):void {
			_pb.removeEventListener(MouseEvent.MOUSE_DOWN, playDown); // Once playback has started, disable button
			stage.addEventListener(MouseEvent.MOUSE_UP, playUp); // Listen for button release on stage
			_pb.x += 2; // Move button down & right
			_pb.y += 2;
			_pb.filters = []; // Hide shadow
		}
		
		// When play button is released
		private function playUp(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, playUp); // Clean up
			_pb.x -= 2; // Move button up & left
			_pb.y -= 2;
			_pb.filters = [_dsf]; // Show shadow
			_pb.buttonMode = false; // Turn off hand cursor
			playSound();
		}
		
		// Enable playback button
		private function enablePlayback():void {
			_pb.buttonMode = true; // Turn on hand cursor
			_pb.addEventListener(MouseEvent.MOUSE_DOWN, playDown); // Listen for button press
		}
		
		// Start MP3 playback
		private function playSound():void {
			// If the file has finished downloading, show the remaining time in text and grahpically
			if(_loaded) {
				this.addEventListener(Event.ENTER_FRAME, playbackProgressBar); // Start time remaining graphic display
				this.addEventListener(Event.ENTER_FRAME, playbackRemainText); // Start time remaining countdown text display
			}
			_sc = _s.play();
			_playing = true;
			this.addEventListener(Event.ENTER_FRAME, playbackProgressText); // Display elapsed playback time
			_sc.addEventListener(Event.SOUND_COMPLETE, soundComplete); // Listen for playback to finish
		}
		
		// Create playback graphic display
		private function initProgressBar():void {
			_sb = new Scrubber(); // graphic play back display is in FLA library
			_sb.width = stage.stageWidth - _sx - 4; // Stretch bar across width of stage
			_sb.x = _sx + 10; // leave a little space between play button (if it exists) and progress bar
			_sb.y = _sb.height * 0.5;
			_sb.bar.scaleX = 0; // Set playback progress bar to 0
			_sb.filters = [_dsf]; // Add shadow
			addChild(_sb);
		}
		
		// Load the sound from URL provided as FlashVars in HTML embed code
		private function initSound():void {
			var request:URLRequest = new URLRequest(_url);
			_s = new Sound();
			_s.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_s.addEventListener(Event.OPEN, downloadOpenHandler);
			_s.addEventListener(ProgressEvent.PROGRESS, preloaderBar);
			_s.addEventListener(ProgressEvent.PROGRESS, preloaderText);
			_s.addEventListener(Event.COMPLETE, downloadCompleteHandler);
			_s.addEventListener(Event.ID3, id3Handler);
			// Try to load the MP3 file. If it fails, display error message
			try {
				_s.load(request);
			} catch (error:Error) {
				_t.text = _sorry; // show error message
				_id3.text = "mp3url=" + _url;
				trace(_url);
			}
		}
		
		// ----------------------------------------- LOADING LISTENERS ----------------------------------------- //
		
		// Triggered as soon as MP3 file has started to download
		private function downloadOpenHandler(event:Event):void {
			_s.removeEventListener(Event.OPEN, downloadOpenHandler); // Clean up
			// Start playback as soon as download starts
			if(!_showPlay && !_waitToPlay) {
				playSound();
			}
			// Enable playback button
			if(_showPlay && !_waitToPlay) {
				enablePlayback();
			}
		}
		
		// Triggered when MP3 file has finished downloading
		private function downloadCompleteHandler(event:Event):void {
			_s.removeEventListener(Event.COMPLETE, downloadCompleteHandler); // Clean up
			_s.removeEventListener(ProgressEvent.PROGRESS, preloaderBar); // Clean up
			_s.removeEventListener(ProgressEvent.PROGRESS, preloaderText); // Clean up
			_sl = event.target.length; // Get MP3 total length in milliseconds
			_loaded = true;
			_t.text = _loadingComplete; // Display download complete message
			// Start playback
			if(!_showPlay && _waitToPlay) {
				playSound();
			}
			// Enable playback button
			if(_showPlay && _waitToPlay) {
				enablePlayback();
			}
			// When the file has finished downloading, show the remaining time in text and grahpically
			if(_playing) {
				this.addEventListener(Event.ENTER_FRAME, playbackProgressBar); // Start time remaining graphic display
				this.addEventListener(Event.ENTER_FRAME, playbackRemainText); // Start time remaining countdown text display
			}
			if(!_gotId3) {
				_id3.text = "";
			}
		}
		
		// This is triggered when the MP3 file can't be downloaded for some reason, i.e. can't be found
		private function ioErrorHandler(event:IOErrorEvent):void {
			_s.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler); // Clean up
			_s.removeEventListener(Event.ID3, id3Handler); // Clean up
			_s.removeEventListener(Event.OPEN, downloadOpenHandler); // Clean up
			_s.removeEventListener(Event.COMPLETE, downloadCompleteHandler); // Clean up
			_s.removeEventListener(ProgressEvent.PROGRESS, preloaderBar); // Clean up
			_s.removeEventListener(ProgressEvent.PROGRESS, preloaderText); // Clean up
			_t.text = _sorry; // Display error message
			_id3.text = "mp3url=" + _url;
		}
		
		// Get and display loaded MP3 file's ID3 tag info - N.B. This is much more reliable in Flash Player 9+
		private function id3Handler(event:Event):void {
			var album:String = _s.id3.album;
			var artist:String = _s.id3.artist;
			var trackNo:String = _s.id3.track;
			var title:String = _s.id3.songName;
			_id3.text = trackNo + ": " + title + ", " + album + ", " + artist; // Display MP3 ID3 info
			_gotId3 = true;
		}
		
		//
		private function soundComplete(event:Event):void {
			_playCount++; // Increase play count by +1
			repeatSound();
		}
		
		// Check number of times played against total permitted
		private function repeatSound():void {
			if(_playCount < _timesToPlay) {
				_sc = _s.play();
			} else {
				_t.text = _finished; // Display message to user
			}
		}
		
		// ----------------------------------------- DISPLAY HANDLERS ----------------------------------------- //
		
		// Display download progress text in percentage
		private function preloaderText(event:ProgressEvent):void {
			var total:uint = event.bytesTotal;
			var loaded:uint = event.bytesLoaded;
			var percent:uint = Math.floor(loaded / total * 100);
			_t.text = _loading + percent + "%";
		}
		
		// Display download progress graphic bar
		private function preloaderBar(event:ProgressEvent):void {
			var total:uint = event.bytesTotal;
			var loaded:uint = event.bytesLoaded;
			var percent:Number = loaded / total;
			_sb.loadBar.scaleX = percent;
		}
		
		// Display elapsed playback time of loaded MP3 file
		private function playbackProgressText(event:Event):void {
			var scPos:int = _sc.position;
			var seconds:int = scPos / 1000;
			var minutes:int = seconds / 60;
			seconds -= minutes * 60;
			var time:String = minutes + ":" + String(seconds + 100).substr(1,2); // Convert it into a human readable string
			_t.text = time;
		}
		
		// Display remaining time on playback (only possible after MP3 has fully downloaded)
		private function playbackRemainText(event:Event):void {
			var scPos:int = _sc.position;
			var remain:int = _sl - scPos;
			var secs:int = remain / 1000;
			var mins:int = secs / 60;
			secs -= mins * 60;
			var rem:String = mins + ":" + String(secs + 100).substr(1,2); // Convert it into a human readable string
			_tr.text = rem;
		}
		
		// Display playback progress graphic (only possible after MP3 has fully downloaded)
		private function playbackProgressBar(event:Event):void {
			var scPos:int = _sc.position;
			var percent:Number = scPos / _sl;
			if(percent <= 0.99) {
				_sb.bar.scaleX = percent;
			} else {
				_sb.bar.scaleX = 1;
			}
		}
	}
}