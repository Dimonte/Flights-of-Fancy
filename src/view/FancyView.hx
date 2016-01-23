package view;
import actionCore.Game;
import actionCore.LevelEdge;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import haxe.ds.HashMap;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.GradientType;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class FancyView extends Sprite
{
	
	var game:Game;
	var modelBitmap:Bitmap;
	var viewportWidth:Int;
	var viewportHeight:Int;
	
	var targetBody:B2Body;
	var modelContainer:Sprite;
	var viewHelper:ViewHelper;
	var levelContainer:Sprite;
	
	var edgeRenderers:Map<LevelEdge, Sprite>;
	var monsterRenderers:Map<B2Body, Sprite>;
	var edgesContainer:Sprite;
	var monsterContainer:Sprite;
	var overlap:Float = 0;
	
	static private inline var TOP_LAYER_OFFSET:Float = -20;
	static private inline var TOP_LAYER_HEIGHT:Float = 60;
	var alternator:Int;
	static inline var alternatorLength:Int = 5;
	

	public function new(game:Game, viewportWidth:Int, viewportHeight:Int) 
	{
		super();
		this.viewportHeight = viewportHeight;
		this.viewportWidth = viewportWidth;
		this.game = game;
		addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		
		graphics.beginFill(0x99CCFF);
		graphics.drawRect(0, 0, viewportWidth, viewportHeight);
		graphics.endFill();
		
		targetBody = game.circleBody;
		
		levelContainer = new Sprite();
		addChild(levelContainer);
		
		edgesContainer = new Sprite();
		levelContainer.addChild(edgesContainer);
		
		modelContainer = new Sprite();
		levelContainer.addChild(modelContainer);
		
		monsterContainer = new Sprite();
		levelContainer.addChild(monsterContainer);
		
		modelBitmap = new Bitmap(Assets.getBitmapData("img/flying.png"));
		modelBitmap.smoothing = true;
		modelContainer.addChild(modelBitmap);
		modelBitmap.x = -modelBitmap.width / 2 - 60;
		modelBitmap.y = -modelBitmap.height / 2 - 90;
		
		edgeRenderers = new Map<LevelEdge, Sprite>();
		monsterRenderers = new Map<B2Body, Sprite>();
		
		
		viewHelper = new ViewHelper(targetBody, viewportWidth, viewportHeight);
	}
	
	private function enterFrameHandler(e:Event):Void 
	{
		viewHelper.update();
		
		modelContainer.x = viewHelper.modelCenter.x;
		modelContainer.y = viewHelper.modelCenter.y;
		
		modelContainer.scaleX = modelContainer.scaleY = viewHelper.scale;
		modelContainer.rotation = viewHelper.modelRotation;
		
		levelContainer.scrollRect = viewHelper.scrollRect;
		
		modelBitmap.bitmapData = game.flying ? Assets.getBitmapData("img/flying.png") : Assets.getBitmapData("img/sliding.png");
		modelBitmap.smoothing = true;
		
		levelContainer.graphics.clear();
		levelContainer.graphics.lineStyle(2, 0xFF0000, 1);
		
		
		
		for (edge in game.levelCreator.edges) 
		{
			if (edgeRenderers[edge] == null)
			{
				
				var sprite:Sprite = new Sprite();
				sprite.x = edge.startPoint.x * 30;
				sprite.y = edge.startPoint.y * 30;
				
				var topColor:UInt = (alternator < alternatorLength) ? 0x66CC33 : 0x77DD44;
				var bottomColor:UInt = 0x339900;
				
				var gfx:Graphics = sprite.graphics;
				gfx.lineStyle(4, topColor);
				gfx.beginFill(topColor);
				gfx.moveTo(0, 0 + TOP_LAYER_OFFSET);
				gfx.lineTo(edge.endPoint.x * 30 + overlap, edge.endPoint.y * 30 + TOP_LAYER_OFFSET);
				gfx.lineTo(edge.endPoint.x * 30 + overlap, edge.endPoint.y * 30 + TOP_LAYER_HEIGHT + overlap);
				gfx.lineTo(0, TOP_LAYER_HEIGHT + overlap);
				gfx.endFill();
				
				gfx.lineStyle(4, bottomColor);
				gfx.beginFill(bottomColor);
				gfx.moveTo(0, TOP_LAYER_HEIGHT);
				gfx.lineTo(edge.endPoint.x * 30 + overlap, edge.endPoint.y * 30 + TOP_LAYER_HEIGHT);
				gfx.lineTo(edge.endPoint.x * 30 + overlap, edge.endPoint.y * 30 + 2000);
				gfx.lineTo(0, 2000);
				
				//sprite.cacheAsBitmap = true;
				edgesContainer.addChild(sprite);
				
				edgeRenderers[edge] = sprite;
				
				alternator++;
				if (alternator >= alternatorLength * 2)
				{
					alternator = 0;
				}
			}
			//levelContainer.graphics.moveTo(edge.startPoint.x * 30 * viewHelper.scale, edge.startPoint.y * 30 * viewHelper.scale);
			//levelContainer.graphics.lineTo(edge.endPoint.x * 30 * viewHelper.scale, edge.endPoint.y * 30 * viewHelper.scale);
		}
		
		for (edge in edgeRenderers.keys())
		{
			if (game.levelCreator.edges.indexOf(edge) == -1)
			{
				edgesContainer.removeChild(edgeRenderers[edge]);
				edgeRenderers.remove(edge);
			}
		}
		
		edgesContainer.scaleX = edgesContainer.scaleY = viewHelper.scale;
		
		for (monster in game.levelCreator.monsters)
		{
			if (monsterRenderers[monster] == null)
			{
				var sprite:Sprite = new Sprite();
				
				var monsterBitmap:Bitmap = new Bitmap(Assets.getBitmapData("img/monster_standing.png"));
				monsterBitmap.smoothing = true;
				monsterBitmap.x = -monsterBitmap.width / 2;
				monsterBitmap.y = -monsterBitmap.height/ 2 - 20;
				sprite.addChild(monsterBitmap);
				sprite.scaleX = sprite.scaleY = 0.75;
				
				monsterContainer.addChild(sprite);
				
				monsterRenderers[monster] = sprite;
			}
		}
		
		for (monster in monsterRenderers.keys())
		{
			if (game.levelCreator.monsters.indexOf(monster) == -1)
			{
				monsterContainer.removeChild(monsterRenderers[monster]);
				monsterRenderers.remove(monster);
			}
			else 
			{
				var monsterSprite:Sprite = monsterRenderers[monster];
				
				var monsterBitmap:Bitmap = cast(monsterSprite.getChildAt(0), Bitmap);
				if (monster.getUserData() == "dead")
				{
					monsterBitmap.bitmapData = Assets.getBitmapData("img/monster_dead.png");
				}
				else if (monster.getType() == B2Body.b2_dynamicBody)
				{
					monsterBitmap.bitmapData = Assets.getBitmapData("img/monster_hanging.png");
				}
				
				var targetAngle:Float = monster.getAngle() * 180 / Math.PI;
				while (targetAngle > 180)
				{
					targetAngle -= 360;
				}
				while (targetAngle < -180)
				{
					targetAngle += 360;
				}
				monsterSprite.rotation += (targetAngle - monsterSprite.rotation) / 10;
				monsterSprite.x = monster.getWorldCenter().x * 30;
				monsterSprite.y = monster.getWorldCenter().y * 30;
			}
		}
		
		monsterContainer.scaleX = monsterContainer.scaleY = viewHelper.scale;
		
		/*
		var targetBodyCenter:B2Vec2 = targetBody.getWorldCenter();
		var targetBodyVelocity:B2Vec2 = targetBody.getLinearVelocity();
		
		var heightScaleMod:Float = Math.max(0, (20 - targetBodyCenter.y));
		var scaleModifier:Float = 1 / (1 + targetBodyVelocity.length() / 10 + heightScaleMod);
		var targetScale:Float = 10 + 20 * scaleModifier;
		currentScale += (targetScale - currentScale) / 20;
		
		//debugDraw.setDrawScale(currentScale);
		
		var velocityModX:Float = targetBodyVelocity.x;
		velocityModX *= velocityModX > 0 ? 0.5 : 0.1;
		
		var heightMod:Float = Math.pow(10 - targetBodyCenter.y, 2) / 100;
		
		modelContainer.x = game.circleBody.getPosition().x * currentScale;
		modelContainer.y = game.circleBody.getPosition().y * currentScale;
		
		modelContainer.scaleX = modelContainer.scaleY = currentScale / 30;
		
		var viewTarget:Point =  new Point(targetBodyCenter.x, targetBodyCenter.y);
		currentViewPosition.x += (viewTarget.x - currentViewPosition.x) / 10;
		currentViewPosition.y += (viewTarget.y - currentViewPosition.y) / 10;
		
		scrollRect = new Rectangle(currentViewPosition.x * currentScale - viewportWidth / 3, currentViewPosition.y  * currentScale - viewportHeight / 2, viewportWidth, viewportHeight);
		*/
	}
	
}