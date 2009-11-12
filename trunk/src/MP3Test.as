/*
MP3 Player for Listening Tests

Copyright (C) 2009 Matt Bury

Website: http://matbury.com/

Contact: matbury@gmail.com

Version: 20091110

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
	
	public class MP3Test extends Sprite {
		
		private var _font:String = "Trebuchet MS"; // This determines all the display text fonts
		// User feedback messages. Edit these to change language
		private var _loading:String = "Loading audio... ";
		private var _waiting:String = "Waiting for MP3 tag info... ";
		private var _finished:String = "The recording has finished.";
		private var _sorry:String = "Sorry, there was a problem with the audio. Please try again or contact admin.";
		// --------------------------------------------------------------------------------------------------------
		private var _url:String; // MP3 file to load and play
		private var _sb:Scrubber; // graphic play back display
		private var _t:TextField; // time elapsed text display
		private var _tr:TextField; // time remaining text display
		private var _id3:TextField; // MP3 ID3 tags text display
		private var _s:Sound; // sound object (contains the loaded MP3 file)
		private var _sc:SoundChannel; // controls playback of sound object
		private var _sl:Number; // the total length of the loaded sound in milliseconds
		private var _timesToPlay:int; // the number of times to play the MP3
		private var _playCount:int = 0; // the number of times the MP3 has been played
		
		public function MP3Test() {
			stage.scaleMode = StageScaleMode.NO_SCALE; // Do not scale the display to fit the Flash Player window
			stage.align = StageAlign.TOP_LEFT; // Anchor the display to the top left of the Flash Player window
			_url = this.root.loaderInfo.parameters.mp3url; // Get the MP3 file URL passed in through FlashVars
			if(this.root.loaderInfo.parameters.timesToPlay) {
				_timesToPlay = this.root.loaderInfo.parameters.timesToPlay;
			} else {
				_timesToPlay = 1;
			}
			initProgressBar(); // Create graphic display
			initTextDisplay(); // Create text display
			playSound(); // Start loading and playing sound
		}
		
		// ----------------------------------------- DISPLAY ----------------------------------------- //
		
		// Create play back graphic display
		private function initProgressBar():void {
			_sb = new Scrubber(); // graphic play back display is in FLA library
			_sb.width = stage.stageWidth - 4;
			_sb.x = 12;
			_sb.y = 10;
			_sb.bar.scaleX = 0;
			addChild(_sb);
		}
		
		// Create the text play back display fields
		private function initTextDisplay():void {
			var f:TextFormat = new TextFormat();
			f.font = "Trebuchet MS";
			f.size = 15;
			f.bold = true;
			// time elapsed
			_t = new TextField();
			_t.autoSize = TextFieldAutoSize.LEFT;
			_t.defaultTextFormat = f;
			_t.x = 2;
			_t.y = 20;
			_t.text = _loading;
			addChild(_t);
			// time remaining
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
		
		// Check to see whether sound is to be repeated or to show ending message
		private function playSound():void {
			if(_playCount < _timesToPlay) {
				initSound();
			} else {
				_t.text = _finished;
			}
		}
		
		// Load the sound from URL provided as FlashVars in HTML embed code
		private function initSound():void {
			//_url = "mp3/little_prince_01.mp3"; // dummy URL for testing purposes
			var request:URLRequest = new URLRequest(_url);
			_s = new Sound();
			_s.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_s.addEventListener(Event.OPEN, openHandler);
			_s.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_s.addEventListener(Event.COMPLETE, completeHandler);
			_s.addEventListener(Event.ID3, id3Handler);
			// Try to load the MP3 file. If it fails, display error message
			try {
				_s.load(request);
			} catch (error:Error) {
				_t.text = _sorry;
			}
		}
		
		// ----------------------------------------- LOADING LISTENERS ----------------------------------------- //
		
		private function openHandler(event:Event):void {
			event.target.removeEventListener(Event.COMPLETE, openHandler); // Clean up
			_sc = event.target.play(); // Start playing MP3 as soon as loading starts
			_sc.addEventListener(Event.SOUND_COMPLETE, soundComplete);
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler); // Start loading and play back graphic display
		}
		
		// Monitor loading progress and update graphic display
		private function progressHandler(event:ProgressEvent):void {
			var loaded:int = event.bytesLoaded;
			var total:int = event.bytesTotal;
			var percent:Number = loaded/total;
			_sb.loadBar.scaleX = percent;
		}
		
		//
		private function completeHandler(event:Event):void {
			event.target.removeEventListener(Event.COMPLETE, completeHandler); // Clean up
			event.target.removeEventListener(ProgressEvent.PROGRESS, progressHandler); // Clean up
			_sl = event.target.length; // Get MP3 total length in milliseconds
			this.addEventListener(Event.ENTER_FRAME, barHandler); // Start time remaining countdown text display
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler); // Clean up
			event.target.removeEventListener(ProgressEvent.PROGRESS, progressHandler); // Clean up
			event.target.removeEventListener(Event.ID3, id3Handler); // Clean up
			event.target.removeEventListener(Event.COMPLETE, openHandler); // Clean up
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler); // Stop loading and play back graphic display
			_t.text = _sorry; // Display error message
			_id3.text = "";
		}
		
		// Get and display loaded MP3 file's ID3 tag info - N.B. This is much more reliable in Flash Player 9+
		private function id3Handler(event:Event):void {
			var album:String = _s.id3.album;
			var artist:String = _s.id3.artist;
			var trackNo:String = _s.id3.track;
			var title:String = _s.id3.songName;
			_id3.text = trackNo + ": " + title + ", " + album + ", " + artist;
		}
		
		//
		private function soundComplete(event:Event):void {
			_playCount++; // Increase play count by +1
			playSound();
		}
		
		// ----------------------------------------- DISPLAY HANDLERS ----------------------------------------- //
		
		// Display elapsed play back time of loaded MP3 file
		private function enterFrameHandler(event:Event):void {
			var scPos:int = _sc.position;
			var seconds:int = scPos / 1000;
			var minutes:int = seconds / 60;
			seconds -= minutes * 60;
			var time:String = minutes + ":" + String(seconds + 100).substr(1,2);
			_t.text = time;
		}
		
		// Update graphic play back display and remaining time text displays
		private function barHandler(event:Event):void {
			var scPos:int = _sc.position;
			var remain:int = _sl - scPos;
			var secs:int = remain / 1000;
			var mins:int = secs / 60;
			secs -= mins * 60;
			var rem:String = mins + ":" + String(secs + 100).substr(1,2);
			_tr.text = rem;
			var percent:Number = scPos / _sl;
			if(percent <= 0.99) {
				_sb.bar.scaleX = percent;
			} else {
				_sb.bar.scaleX = 1;
				this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
	}
}