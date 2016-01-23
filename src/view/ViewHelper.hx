package view;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import openfl._v2.geom.Point;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class ViewHelper
{
	var viewportMod:Float;
	public var modelRotation:Float;
	public var currentScale:Float = 30;
	public var viewportWidth:Float;
	public var viewportHeight:Float;
	public var targetBody:B2Body;
	public var currentViewPosition:Point;
	public var scrollRect:Rectangle;
	public var modelCenter:Point;
	public var scale:Float;

	public function new(targetBody:B2Body, viewportWidth:Float, viewportHeight:Float) 
	{
		this.viewportHeight = viewportHeight;
		this.viewportWidth = viewportWidth;
		
		viewportMod = viewportWidth / 1920;
		
		this.targetBody = targetBody;
		currentViewPosition = new Point();
		modelCenter = new Point();
		modelRotation = 0;
	}
	
	public function update()
	{
		var targetBodyCenter:B2Vec2 = targetBody.getWorldCenter();
		var targetBodyVelocity:B2Vec2 = targetBody.getLinearVelocity();
		
		var heightScaleMod:Float = Math.max(0, (0 - targetBodyCenter.y));
		var scaleModifier:Float = 1 / (1 + targetBodyVelocity.length() / 10 + heightScaleMod);
		
		
		var targetScale:Float = 8 + 22 * scaleModifier;
		targetScale *= 2.5 * viewportMod;
		
		currentScale += (targetScale - currentScale) / 20;
		
		//debugDraw.setDrawScale(currentScale);
		
		var velocityModX:Float = targetBodyVelocity.x;
		velocityModX *= velocityModX > 0 ? 0.5 : 0.1;
		
		
		
		modelCenter.x = targetBody.getPosition().x * currentScale;
		modelCenter.y = targetBody.getPosition().y * currentScale;
		
		scale = currentScale / 30;
		
		var targetRotation:Float = Math.atan2(targetBodyVelocity.y, targetBodyVelocity.x) * 180 / Math.PI;
		
		modelRotation += (targetRotation - modelRotation)/10;
		
		var targetHeightMod:Float = ( -targetBodyCenter.y / 2);
		targetHeightMod = Math.max(0, targetHeightMod);
		//SOSLog.sosTrace( "targetHeightMod : " + targetHeightMod );
		
		var viewTarget:Point =  new Point(targetBodyCenter.x + targetBodyVelocity.x / 3, targetBodyCenter.y + targetHeightMod);
		currentViewPosition.x += (viewTarget.x - currentViewPosition.x) / 10;
		currentViewPosition.y += (viewTarget.y - currentViewPosition.y) / 10;
		
		scrollRect = new Rectangle(currentViewPosition.x * currentScale - viewportWidth / 3, currentViewPosition.y  * currentScale - viewportHeight / 2, viewportWidth, viewportHeight);
	}
	
}