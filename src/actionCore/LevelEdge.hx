package actionCore;
import box2D.common.math.B2Vec2;
import openfl.geom.Point;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class LevelEdge
{
	public var startPoint:B2Vec2;
	public var endPoint:B2Vec2;
	
	public function new(startPoint:B2Vec2, endPoint:B2Vec2) 
	{
		this.startPoint = startPoint;
		this.endPoint = endPoint;
	}
	
}