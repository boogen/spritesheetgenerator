package {
	import com.adobe.images.PNGEncoder;
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Marcin Bugala
	 */
	public class Main extends Sprite {
		
		private var _assets:Vector.<Object>;
		private var _assetsToLoad:int;
		
		public function Main():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			// entry point
			
			getFiles();
		}
		
		private function pngFilter(obj:Object, index:int, array:Array):Boolean {
			return (obj.name.indexOf(".png") >= 0)
		}
		
		private function filterPngs(list:Array):Array {
			return list.filter(pngFilter);
		}
		
		private function getFiles():void {
			var directory:File = File.applicationDirectory;
			var list:Array = filterPngs(directory.getDirectoryListing());
			
			_assets = new Vector.<Object>();;
			_assetsToLoad = list.length;
			
			for (var i:uint = 0; i < list.length; i++) {
				var loader:Loader = new Loader();
				loader.name = list[i].name;
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.load(new URLRequest((list[i] as File).name));
			}
		}
		
		private function onComplete(e:Event):void {
			_assetsToLoad--;
			var bitmap:Bitmap = e.target.content as Bitmap;
			var name:String = (e.target as LoaderInfo).loader.name;
			_assets.push({"bitmap":bitmap, "name":name});
			
			if (_assetsToLoad == 0) {
				var i:int;
				
				var spritesheet:Spritesheet =  new Spritesheet();
				var result:Object = spritesheet.generate(_assets);
				
				var fileName:String = "spritesheet";
				var xml:String = serializeAnimation(result.animation);
				var xmlFile:File = File.applicationStorageDirectory.resolvePath(fileName + ".xml");
				var xmlStream:FileStream = new FileStream();
				xmlStream.open(xmlFile, FileMode.WRITE);			
				xmlStream.writeUTFBytes(xml);
				xmlStream.close();					
				
				var bArray:ByteArray = PNGEncoder.encode(result.bitmapData);
				
				var file:File = File.applicationStorageDirectory.resolvePath(fileName + ".png");
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeBytes(bArray);
				fileStream.close();			
				
				addChild(new Bitmap(result.bitmapData));
			}
		}
		
		private function serializeAnimation(anim:Vector.<Frame>):String {
			var xml:String = "<spritesheet>";
			for (var i:int = 0; i < anim.length; ++i) {
				var f:Frame = anim[i];
				xml += "<sprite name=\"" + f.name + "\">";
				xml += "<dimension x=\"" + f.dimension.x + "\" y=\"" + f.dimension.y + "\" width=\"" + f.dimension.width + "\" height=\"" + f.dimension.height + "\"></dimension>";
				xml += "</sprite>";
				
			}
			xml += "</spritesheet>";
			
			return xml;
		}		
		
		private function deactivate(e:Event):void {
			// auto-close
			NativeApplication.nativeApplication.exit();
		}
	
	}

}