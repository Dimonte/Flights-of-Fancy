package actionCore;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class LevelCreator 
{
	private var world:B2World;
	private var resolution:Int;
	private var currentX:Float;
	private var currentY:Float;
	private var physScale:Float;
	private var polyIndex:Array<B2Body>;
	public var monsters:Array<B2Body>;
	public var edges:Array<LevelEdge>;
	
	public function new(world:B2World, physScale:Float) 
	{
		this.physScale = physScale;
		this.world = world;
		resolution = 40;
		currentX = 0;
		currentY = 200;
		
		polyIndex = [];
		edges = [];
		monsters = [];
	}
	
	public function createFeature():Void
	{
		var featureHeight:Int;
		var numSteps:Int;
		
		var featureWidth:Int = Std.int(Math.random() * 600 + 1600);
		
		numSteps = Std.int(featureWidth / resolution);
		
		var midPoint:Int = Std.int((numSteps - Math.random() * Math.random() * numSteps) / 3 + numSteps / 3);
		//var midPoint:Int = Std.int(numSteps / 2 + Math.random()*numSteps/4);
		
		featureHeight = Std.int((Math.random() * featureWidth/4 + featureWidth/2) / resolution / 3) * resolution ;
		for (j in 0...midPoint) 
		{
			var startPoint:B2Vec2 = new B2Vec2(currentX, currentY);
			currentX += resolution;
			currentY += Math.sin(j / midPoint * Math.PI) * featureHeight / midPoint * 2;
			var endPoint:B2Vec2 = new B2Vec2(currentX, currentY);
			createPoly(startPoint, endPoint);
		}
		
		if (Math.random() < 0.2)
		{
			createMonsterAt(currentX, currentY);
		}
		
		for (j in midPoint...numSteps) 
		{
			var startPoint:B2Vec2 = new B2Vec2(currentX, currentY);
			currentX += resolution;
			currentY += Math.sin((j - midPoint) / (numSteps - midPoint) * Math.PI + Math.PI) * featureHeight / (numSteps - midPoint) * 2;
			var endPoint:B2Vec2 = new B2Vec2(currentX, currentY);
			createPoly(startPoint, endPoint);
		}
		
		if (Math.random() < 0.2)
		{
			createMonsterAt(currentX, currentY);
		}
	}
	
	function createPoly(startPoint:B2Vec2, endPoint:B2Vec2) 
	{
		endPoint.subtract(startPoint);
		endPoint.multiply(1 / physScale);
		startPoint.multiply(1 / physScale);
		
		var polygon:B2Body = world.createBody(new B2BodyDef());
		polygon.setUserData("level");
		var polyShape:B2PolygonShape = new B2PolygonShape();
		polyShape.setAsEdge(new B2Vec2(0, 0), endPoint);
		polygon.createFixture2(polyShape, 1);
		polygon.setPosition(startPoint);
		polyIndex.push(polygon);
		
		var endEdge:B2Vec2 = endPoint.copy();
		//endEdge.add(endPoint);
		edges.push(new LevelEdge(startPoint.copy(), endEdge));
	}
	
	function createMonsterAt(currentX:Float, currentY:Float) 
	{
		var monster:B2Body = world.createBody(new B2BodyDef());
		monster.setType(B2Body.b2_staticBody);
		monster.setUserData("monster");
		
		var fixtureDef:B2FixtureDef = new B2FixtureDef();
		fixtureDef.shape = new B2CircleShape(30/physScale);
		fixtureDef.restitution = 0;
		fixtureDef.density = 0.8;
		fixtureDef.friction = 0;
		fixtureDef.isSensor = true;
		monster.createFixture(fixtureDef);
		monster.setPosition(new B2Vec2(currentX/physScale, (currentY - 50)/physScale));
		//monster.setLinearVelocity(new B2Vec2(30, -20));
		monster.setAngularDamping(0.5);
		monster.setLinearDamping(1);
		
		monsters.push(monster);
	}
	
	public function getCurrentLength():Float
	{
		return currentX/physScale;
	}
	
	public function clearUpTo(targetX:Float):Void
	{
		var leftmostPolygon:B2Body = polyIndex[0];
		while (leftmostPolygon != null && leftmostPolygon.getPosition().x < targetX) 
		{
			
			world.destroyBody(polyIndex.shift());
			leftmostPolygon = polyIndex[0];
			edges.shift();
		}
		
		for (monster in monsters)
		{
			if (monster.getWorldCenter().x < targetX)
			{
				monsters.remove(monster);
			}
		}
	}
	
}

