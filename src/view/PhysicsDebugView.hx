package view ;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2World;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import view.ViewHelper;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class PhysicsDebugView extends Sprite
{
	private var targetBody:B2Body;
	
	private var world:B2World;
	private var debugDraw:B2DebugDraw;
	private var currentViewPosition:Point;
	private var viewportWidth:Float;
	private var viewportHeight:Float;
	private var currentScale:Float;
	var viewHelper:ViewHelper;
	
	public function new(world:B2World, viewportWidth:Float, viewportHeight:Float, targetBody:B2Body) 
	{
		super();
		this.viewportHeight = viewportHeight;
		this.viewportWidth = viewportWidth;
		this.world = world;
		currentScale = 30;
		debugDraw = new B2DebugDraw();
		debugDraw.setDrawScale(currentScale);
		debugDraw.setFlags(B2DebugDraw.e_shapeBit | B2DebugDraw.e_jointBit);
		debugDraw.setSprite(this);
		world.setDebugDraw(debugDraw);
		currentViewPosition = new Point();
		addEventListener(Event.ENTER_FRAME, enterFrame);
		
		viewHelper = new ViewHelper(targetBody, viewportWidth, viewportHeight);
	}
	
	private function enterFrame(e:Event):Void 
	{		
		viewHelper.update();
		
		scrollRect = viewHelper.scrollRect;
		
		debugDraw.setDrawScale(viewHelper.scale * 30);
		
		/*
		if (targetBody != null) 
		{
			var targetBodyCenter:B2Vec2 = targetBody.getWorldCenter();
			var targetBodyVelocity:B2Vec2 = targetBody.getLinearVelocity();
			
			var heightScaleMod:Float = Math.max(0, (20 - targetBodyCenter.y));
			var scaleModifier:Float = 1 / (1 + targetBodyVelocity.length() / 10 + heightScaleMod);
			var targetScale:Float = 10 + 20 * scaleModifier;
			currentScale += (targetScale - currentScale) / 20;
			
			debugDraw.setDrawScale(currentScale);
			
			var velocityModX:Float = targetBodyVelocity.x;
			velocityModX *= velocityModX > 0 ? 0.5 : 0.1;
			
			var heightMod:Float = Math.pow(10 - targetBodyCenter.y, 2) / 100;
			
			var viewTarget:Point =  new Point(targetBodyCenter.x, targetBodyCenter.y);//new Point(targetBodyCenter.x + velocityModX, targetBodyCenter.y + targetBodyVelocity.y/5 + heightMod);
			currentViewPosition.x += (viewTarget.x - currentViewPosition.x) / 10;
			currentViewPosition.y += (viewTarget.y - currentViewPosition.y) / 10;
			
		}
		
		scrollRect = new Rectangle(currentViewPosition.x * currentScale - viewportWidth / 3, currentViewPosition.y  * currentScale - viewportHeight / 2, viewportWidth, viewportHeight);
		*/
		world.drawDebugData();
	}
	
}