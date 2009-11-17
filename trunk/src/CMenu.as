/*
CMenu class by Matt Bury

Copyright (C) 2009 Matt Bury
Website: http://matbury.com/
Contact: matbury@gmail.com

Example code:
var cmenu:CMenu = new CMenu();
addChild(cmenu);
cmenu.addCMenu();

This program is free software: You can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public Licence along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

package {
	
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.ContextMenuBuiltInItems;
	import flash.events.ContextMenuEvent;
	import flash.display.Sprite;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	public class CMenu extends Sprite {
		
		private var _cm:ContextMenu;
		private var _url:String = "http://matbury.com/";
		private var _licence:String = "http://matbury.com/";
		
		public function CMenu() {
			_cm = new ContextMenu();
			removeDefaultItems();
			addCustomItems();
		}
		
		// Remove default context menu items
		private function removeDefaultItems():void {
			_cm.hideBuiltInItems();
			var defaultItems:ContextMenuBuiltInItems = _cm.builtInItems;
            defaultItems.print = true;
		}
		
		// Customise menu items
		private function addCustomItems():void {
			// Copyright
			var c:String = String.fromCharCode(169);
			var date:Date = new Date();
			var year:String = date.fullYear.toString();
			var copyright:ContextMenuItem = new ContextMenuItem(c + " " + year + " Matt Bury matbury@gmail.com");
			_cm.customItems.push(copyright);
			// link to GPL licence
			var licence:ContextMenuItem = new ContextMenuItem("GPL3 Open Source licence...");
			_cm.customItems.push(licence);
			licence.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, licenceHandler);
			// link to matbury.com
			var matbury:ContextMenuItem = new ContextMenuItem("About matbury.com...");
			_cm.customItems.push(matbury);
			matbury.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, matburyHandler);
		}
		
		// Open new browser page to GPL open source licence
		private function licenceHandler(event:ContextMenuEvent):void {
			var request:URLRequest = new URLRequest(_licence);
			navigateToURL(request,"_blank");
		}
		
		// Open new browser page to author's web site
		private function matburyHandler(event:ContextMenuEvent):void {
			var request:URLRequest = new URLRequest(_url);
			navigateToURL(request,"_blank");
		}
		
		// Add context menu to the main stage
		public function addCMenu():void {
			parent.contextMenu = _cm;
		}
	}
}