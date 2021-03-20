package  {
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.utils.getDefinitionByName;
	public class SWFAction {

		 
		public static var actions:Object = {};
		public static var generated:Object ={};
		public static function writeAction(target:MovieClip,action:XML){
			var _name = flash.utils.getQualifiedClassName(target);
			if (actions[_name] == undefined ){
				actions[_name] = {};
			}
			if(actions[_name]["frame"+target.currentFrame] == undefined){
				actions[_name]["frame"+target.currentFrame] = {};
			}
			actions[_name]["frame"+target.currentFrame].action = action.toString();
		}
		
		public static function generateHaxeClassFor(movieClips:Array){
			SWFAction.actions = [];
			SWFAction.generated = [];
			var collectted:Array = [];
			var classNames:Array = [];
			for(var i:int = 0;i<movieClips.length;i++){
				var myClass:Class = getDefinitionByName(movieClips[i]) as Class;
				var instance:MovieClip = new myClass() as MovieClip;
				instance.gotoAndStop(1);
				collectted.push(instance);
			}
			
			while(collectted.length != 0){
			 
				classNames.push(flash.utils.getQualifiedClassName(collectted[0]));
				 
				var current:MovieClip = collectted[0] as MovieClip;
				while(current.currentFrame != current.totalFrames){
					var children = [];
					for(var k:int = 0;k < current.numChildren;k++){
						children.push(current.getChildAt(k));
					}
					for(var g:int = 0;g<children.length;g++){
						var child = children[g];
						if(child is MovieClip){
							var _name = flash.utils.getQualifiedClassName(child);
							var has:Boolean = false;
							 
							for(var j:int = 0;j<classNames.length;j++){
								if(classNames[j] == _name){
									has = true;
									break;
								}
							}
							  
							(!has || _name == "flash.display::MovieClip") && collectted.push(child);
						}
					}
						
					 
					current.nextFrame();
					 
				}
				collectted.shift();
			}
			
			
			
			
		}
		
		
		
	}
	
}
