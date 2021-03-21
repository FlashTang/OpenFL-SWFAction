package;

 
import openfl.display.Sprite;
import haxe.Json.parse;
import sys.io.File;

typedef MovieClipModel = {
    var root:Int;
    var uuid:String;
	var symbols:Array<MovieClipSymbol>;
}
typedef MovieClipSymbol = {
	var type:Int;
	var className:String;
	var id:Int;
	var frames:Array<MovieClipFrame>;
}

typedef MovieClipFrame = {
	var scriptSource:String;
	var objects:Array<MovieClipObject>;
}
typedef MovieClipObject = {
	var name:String;
}
 
class Main extends Sprite
{
	public function new()
	{
		super();
		var dataPath:String = "/Users/tang/Desktop/game.zip";
		var mainFolderPath = "";
		var classOutputPathComponents = dataPath.split("/");
		for(i in 0...classOutputPathComponents.length-1){
			mainFolderPath = mainFolderPath + classOutputPathComponents[i] + "/";
		}
		var zipFileName:String = classOutputPathComponents[classOutputPathComponents.length-1].split(".")[0];

		var classOutputPath = mainFolderPath + zipFileName + "_classes";
		var tempJsonFilePath = mainFolderPath + "temp_json_files";

		sys.FileSystem.createDirectory(tempJsonFilePath);
		sys.FileSystem.createDirectory(classOutputPath);
		Main.generateClass(dataPath,classOutputPath,function() {
			 
				var json = sys.io.File.getContent(tempJsonFilePath + "/data.json");
				var dataJson:MovieClipModel = haxe.Json.parse(json);
				
				for(j in 0...dataJson.symbols.length){
					var mSymbol:MovieClipSymbol = dataJson.symbols[j];
					var r = new EReg(Std.string(mSymbol.className), "i");
					
					if(!r.match("MainTimeline")){
						var t_action = getTemplate("Mac")+"\""+dataJson.uuid+"\""+");"+"\n"+"\t\tvar symbol = library.symbols.get("+mSymbol.id+");";
						var fileName:String = Std.string(mSymbol.className);
						var executeToAdd:String = "";
						var functionToAdd:String = "";
						var objVars:String = "";
						if(mSymbol.frames != null){
							for(f in 0...mSymbol.frames.length){
								var frame = mSymbol.frames[f];
								if(frame != null && frame.scriptSource != null){
									var addFrameScript = "		addFrameScript("+f+",frame"+(f+1)+"Action);";
									executeToAdd += addFrameScript+"\n";
									var rawAction:String = Std.string(frame.scriptSource);
									var rawActionComponents = rawAction.split("<![CDATA[");
									 
									var actionHandler:String = "\n	function frame"+(f+1)+"Action()\n	{\n";
									if(rawActionComponents.length > 1){
										var actions = rawActionComponents[1].split("]]>");
										actions.pop();
										var action = "";
										for(a in 0...actions.length){
											action += actions[a];
										}
										actionHandler += action+"\n	}";
									} 
									functionToAdd += actionHandler+"\n";

								}

								if(frame.objects != null){
									for(o in 0...frame.objects.length){
										if(frame.objects[o].name != null) {
											objVars += frame.objects[o].name
										}
									}
								}
								
							}

							var action_to_write:String = t_action + "\n"+executeToAdd+"\n	}"+functionToAdd+"\n}";
							sys.io.File.saveContent(classOutputPath+"/"+fileName+".hx",action_to_write);
							 
						}
 
					}
					else{
						//MainTimeline
					}
				}
			
			 
		 
			trace("Classes generated in folder : " + classOutputPath);
			trace(getTemplate());
		},tempJsonFilePath);
	}

	public static function getVarString(obj_name:String):String {
		return "@:keep @:noCompletion @:dox(hide) public var "+obj_name+"(default, null):Idle";
	}

	public static function generateClass(dataPath,classOutputPath,onComplete:()->Void,tempJsonFilePath:String){
		unzip(dataPath,tempJsonFilePath,function(){
			onComplete();
		});
	}

	public static function getTemplate(type:String = "Mac"):String{
		var macHeader:String = "package ;

@:access(swf.exporters.animate)

class Hero extends #if flash flash.display.MovieClip.MovieClip2 #else openfl.display.MovieClip #end
{
	
	public function new()
	{
		super();

		var library = swf.exporters.animate.AnimateLibrary.get(";

		
		return macHeader;
	}

	public static var footer:String = "
		}
	}";

	public static function unzip( _path:String, _dest:String,onComplete:()->Void, ignoreRootFolder:String = "" ) {

        var _in_file = sys.io.File.read( _path );
        var _entries = haxe.zip.Reader.readZip( _in_file );

            _in_file.close();

        for(_entry in _entries) {
            
            var fileName = _entry.fileName;
            if (fileName.charAt (0) != "/" && fileName.charAt (0) != "\\" && fileName.split ("..").length <= 1) {
                var dirs = ~/[\/\\]/g.split(fileName);
                if ((ignoreRootFolder != "" && dirs.length > 1) || ignoreRootFolder == "") {
                    if (ignoreRootFolder != "") {
                        dirs.shift ();
                    }
                
                    var path = "";
                    var file = dirs.pop();
                    for( d in dirs ) {
                        path += d;
                        sys.FileSystem.createDirectory(_dest + "/" + path);
                        path += "/";
                    }
                
                    if( file == "" ) {
                        if( path != "" ) //Run._trace("created " + path);
                        continue; // was just a directory
                    }
                    path += file;
                    // Run._trace("unzip " + path);
                
                    var data = haxe.zip.Reader.unzip(_entry);
                    var f = File.write (_dest + "/" + path, true);
                    f.write(data);
                    f.close();
                }
            }
        } //_entry

        Sys.println('');
        Sys.println('unzipped successfully to ${_dest}');
		onComplete();
    } //unzip
}
