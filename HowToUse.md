This Flash application requires a moderate amount of web developer knowledge to be used successfully, although a beginner may be able to use and adapt the code given on this page by following the instructions carefully. Please note that I, Matt Bury, do not have the time to provide support to users who encounter problems with embedding the player. The embed code provided here is well known and the majority of web designers and web developers should have no problem in providing help. Also, please see the section below titled, "Possible problems" before seeking help.

You can copy and paste this code into any HTML web page using a web or text editor. There are five lines of this code that you'll need to modify to make it work on your web site with the desired MP3 audio files:

```
<div align="center">
<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="600" height="100" id="myFlashContent">
	<param name="movie" value="swf/mp3_test.swf" />
	<param name="flashvars" value="mp3url=mp3/little_prince_01.mp3&amp;timesToPlay=2&amp;showPlay=true&amp;waitToPlay=true" />
	<!--[if !IE]>-->
	<object type="application/x-shockwave-flash" data="swf/mp3_test.swf" width="600" height="100">
		<param name="flashvars" value="mp3url=mp3/little_prince_01.mp3&amp;timesToPlay=2&amp;showPlay=true&amp;waitToPlay=true" />
	<!--<![endif]-->
		<a href="http://www.adobe.com/go/getflashplayer">
			<img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />
		</a>
	<!--[if !IE]>-->
	</object>
	<!--<![endif]-->
</object>
</div>
```

In both sets of lines, 3, 4 & 5 and 7 & 8, there are seven parameters**:
>**<table cellpadding='10' width='100%' border='0'>
<blockquote><tr>
<blockquote><td width='3%'>1.</td>
<td width='9%'>data/value</td>
<td width='19%'><strong>swf/mp3_test.swf</strong></td>
<td width='19%'>(required)</td>
<td width='50%'>The Flash MP3 player</td>
</blockquote></tr>
<tr>
<blockquote><td>2.</td>
<td>mp3url</td>
<td><strong>mp3/little_prince_01.mp3</strong></td>
<td>(required)</td>
<td>The MP3 file to load</td>
</blockquote></tr>
<tr>
<blockquote><td>3.</td>
<td>width</td>
<td><strong>600</strong></td>
<td>(required)</td>
<td>Width in pixels of the Flash Player window</td>
</blockquote></tr>
<tr>
<blockquote><td>4.</td>
<td>height</td>
<td><strong>100</strong></td>
<td>(required)</td>
<td>Height in pixels of the Flash Player window</td>
</blockquote></tr>
<tr>
<blockquote><td>5.</td>
<td>timesToPlay</td>
<td><strong>2</strong></td>
<td>(optional) default = 1</td>
<td>Number of times to play MP3 file</td>
</blockquote></tr>
<tr>
<blockquote><td>6.</td>
<td>showPlay</td>
<td><strong>true</strong></td>
<td>(optional) default = false</td>
<td>Show play button for user to click</td>
</blockquote></tr>
<tr>
<blockquote><td>7.</td>
<td>waitToPlay</td>
<td><strong>true</strong></td>
<td>(optional) default = false</td>
<td>Wait for download to complete before playing</td>
</blockquote></tr>
<tr>
<blockquote><td>8.</td>
<td>showID3</td>
<td><strong>true</strong></td>
<td>(optional) default = false</td>
<td>Display MP3 ID3 tags (track number, title, album, artist)</td>
</blockquote></tr>
<tr>
<blockquote><td>9.</td>
<td>addHttp</td>
<td><strong>false</strong></td>
<td>(optional) default = false</td>
<td>Append "http://" to the mp3url parameter. (Workaround for link filters)</td>
</blockquote></tr>
</blockquote><blockquote></table></blockquote>

Please note that "&amp;" is a separator between the parameters.

1 & 2. MP3 Player URLs and Audio File URLs: This is the path to the mp3\_test.swf application and the MP3 audio file from the web page. In Moodle, for example, it's best practice to store media files in the moodledata directory and access them via file.php. The following lines assume that your Moodle is at http://moodlesite.com/, the ID number of the course you want to embed the MP3 Player in is 99 and the Flash and MP3 files are stored in the moodledata course files directory:

```
3. <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="600" height="100" id="myFlashContent">
4. <param name="movie" value="http://moodlesite.com/file.php/99/swf/mp3_test.swf" />
5. <param name="flashvars" value="mp3url=http://moodlesite.com/file.php/99/mp3/little_prince_01.mp3&amp;timesToPlay=2&amp;showPlay=true&amp;waitToPlay=true" />

and

7. <object type="application/x-shockwave-flash" data="http://moodlesite.com/file.php/99/swf/mp3_test.swf" width="600" height="100">
8. <param name="flashvars" value="mp3url=http://moodlesite.com/file.php/99/mp3/little_prince_01.mp3&amp;timesToPlay=2&amp;showPlay=true&amp;waitToPlay=true" />
```

3 & 4. The Flash Player window dimensions: These determine the width and height of the Flash Player window in which the application appears. The MP3 Player automatically adjusts to the width of the window but not the height. I recommend experimenting with these parameters to see what happens. For example, if you set the height to less than 50 pixels, the ID3 data display at the bottom, i.e. MP3 track information, will be concealed.

5. Number of times to play the MP3 file: This parameter is optional and the default is 1. You can try changing the number to see what happens but it's pretty self-explanatory.

6. Show play button: This parameter is optional and the default is false. Setting it to true displays a play button and the MP3 player waits for the user to click on it to start playing the loaded MP3 file. Playback can start before the MP3 file has finished loading, otherwise known as progressive download.

7. Wait to play: This parameter is optional and the default is false. Setting it to true tells the player to wait until the loaded MP3 file has finished downloading before allowing playback to start. This is useful if you anticipate slow or intermittent internet connections that could interrupt the download while the student is listening.

8. Show MP3 ID3 tags: This parameter is optional and the default is false. Setting it to true displays the current MP3 file's track number, title, album and artist. If the ID3 tags are not accessible in the MP3 file, the player displays "Waiting for ID3 tags..." and waits until the MP3 file has downloaded compeletly before clearing the ID3 tag display.

9. Add HTTP: This parameter is optional. It is a workaround for CMSs that use link filters indiscriminately and add an `<a href=""></a>` tag wherever they find `http://` on a page. With `addHttp=true`, you can omit the `http://` from the `mp3url` parameter and the MP3 Player for Tests will add it once it has been passed in.

Here is a full example with the addHttp=true parameter:
```
<div align="center">
	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="800" height="100" id="myFlashContent">
		<param name="movie" value="http://yourmoodle.com/moodle/file.php/7/swf/mp3_test.swf" />
		<param name="flashvars" value="mp3url=yourmoodle.com/moodle/file.php/7/mp3/cae_2008_book_2_test_1_part_1.mp3&amp;timesToPlay=2&addHttp=true" />
		<!--[if !IE]>-->
		<object type="application/x-shockwave-flash" data="http://yourmoodle.com/moodle/file.php/7/swf/mp3_test.swf" width="800" height="100">
			<param name="flashvars" value="mp3url=yourmoodle.com/moodle/file.php/7/mp3/cae_2008_book_2_test_1_part_1.mp3&amp;timesToPlay=2&addHttp=true" />
		<!--<![endif]-->
			<a href="http://www.adobe.com/go/getflashplayer">
				<img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />
			</a>
		<!--[if !IE]>-->
		</object>
		<!--<![endif]-->
	</object>
</div>
```

---


## Possible problems ##

Please note that some learning management systems use filtres that strip out certain types of code. If this embed code doesn't work, firstly, check that the code doesn't contain any errors and that the paths to the Flash and audio files are valid (copy and paste them into your browser's address bar), then check that your learning management system allows `<object>` and `<embed>` tags, which are necessary to embed Flash applications. You may need administrator priviledges to change these settings.


---


## Future versions ##

If you have any requests for new features, find any bugs or would like to see something improved, please let me know on here or on the issues tracker on this project site.

Good luck!