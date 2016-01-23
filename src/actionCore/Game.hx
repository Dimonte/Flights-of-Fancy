package actionCore;
import actionCore.LevelCreator;
import box2D.collision.shapes.B2CircleShape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import box2D.dynamics.contacts.B2ContactEdge;
import box2D.dynamics.joints.B2DistanceJoint;
import box2D.dynamics.joints.B2DistanceJointDef;
import box2D.dynamics.joints.B2JointEdge;
import com.iainlobb.gamepad.Gamepad;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.Lib;
import view.FancyView;
import view.PhysicsDebugView;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class Game extends Sprite
{
	public static var instance:Game;
	static public inline var MIN_SPEED:Float = 4;
	
	public var world:B2World;
	private var _viewportWidth:Int;
	private var _viewportHeight:Int;
	private var physScale:Float = 30;
	private var gamepad:Gamepad;
	public var circleBody:B2Body;
	private var debugView:PhysicsDebugView;
	public var levelCreator:LevelCreator;
	var mouseDown:Bool;
	var fancyView:FancyView;
	
	var lastInChain:B2Body;
	var chainStart:B2Body;
	var chainEnd:B2Body;
	var chain:Array<B2Body>;
	
	var kickoffTime:Int;
	var deadMonsters:Array<B2Body>;
	
	public var flying:Bool = true;
	
	public function new(viewportWidth:Int, viewportHeight:Int) 
	{
		super();
		this._viewportHeight = viewportHeight;
		this._viewportWidth = viewportWidth;
		world = new B2World(new B2Vec2(0, 0), true);
		
		chain = [];
		deadMonsters = [];
		
		addObjects();
		createLevel();
		
		
		
		fancyView = new FancyView(this, viewportWidth, viewportHeight);
		addChild(fancyView);
		
		/*
		debugView = new PhysicsDebugView(world, viewportWidth, viewportHeight, circleBody);
		addChild(debugView);
		//*/
		
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		
		instance = this;
	}
	
	public function start()
	{
		addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 100);
	}
	
	private function removedFromStageHandler(e:Event):Void 
	{
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
	}
	
	private function createLevel():Void 
	{
		levelCreator = new LevelCreator(world, physScale);
		
		while (levelCreator.getCurrentLength() < 100)
		{
			levelCreator.createFeature();
		}
	}
	
	private function enterFrameHandler(e:Event):Void 
	{
		var i:Int = Math.round(60 / Lib.current.stage.frameRate);
		while (i-- > 0)
		{
			if (circleBody != null) 
			{
				handleCircleBody();
			}
			
			
			while (circleBody.getWorldCenter().x + 60 > levelCreator.getCurrentLength()) 
			{
				levelCreator.createFeature();
			}
			
			
			
			world.step(0.033, 10, 10);
			world.clearForces();
			
			if (circleBody != null) 
			{
				levelCreator.clearUpTo(circleBody.getWorldCenter().x - 40);
			}
		}
	}
	
	private function handleCircleBody():Void 
	{
		
		var bodyTouchingSlope:Bool = circleBody.getContactList() != null;
		
		bodyTouchingSlope = false;
		
		var contactEdge:B2ContactEdge = circleBody.getContactList();
		while(contactEdge != null)
		{
			if (getUserDataForBodyA(contactEdge) == "level" || getUserDataForBodyB(contactEdge) == "level")
			{
				bodyTouchingSlope = true;
			}
			if (getUserDataForBodyA(contactEdge) == "monster" || getUserDataForBodyB(contactEdge) == "monster")
			{
				var monsterBody:B2Body = (getUserDataForBodyA(contactEdge) == "monster") ? contactEdge.contact.getFixtureA().getBody() : contactEdge.contact.getFixtureB().getBody();
				if (monsterBody.getType() == B2Body.b2_staticBody)
				{
					monsterBody.setType(B2Body.b2_dynamicBody);
					var newPosition:B2Vec2 = chainEnd.getWorldCenter();
					newPosition.add(new B2Vec2( -3, 0));
					monsterBody.setPosition(newPosition);
					monsterBody.setLinearVelocity(circleBody.getLinearVelocity());
					var jointDef:B2DistanceJointDef = new B2DistanceJointDef();
					
					chainEnd.setAngle(0);
					
					var anchorPosA:B2Vec2 = chainEnd.getWorldCenter();
					anchorPosA.add(new B2Vec2(-2, 0));
					var anchorPosB:B2Vec2 = monsterBody.getWorldCenter();
					anchorPosB.add(new B2Vec2(2, 0));
					
					var jointLength:Float = 1;
					
					if (chainEnd == chainStart)
					{
						jointLength = 1;
						anchorPosA.add(new B2Vec2( -2, 0));
					}
					else 
					{
						jointLength= 0.5;
					}
					
					jointDef.initialize(chainEnd, monsterBody, anchorPosA, anchorPosB);
					jointDef.frequencyHz = 1;
					jointDef.dampingRatio = 0.5;
					jointDef.length = jointLength;
					
					world.createJoint(jointDef);
					chainEnd = monsterBody;
					chain.push(monsterBody);
					
					setKickoffTime(); 
				}
			}
			contactEdge = contactEdge.next;
		}
		
		circleBody.applyForce(new B2Vec2(0, 9.5), circleBody.getWorldCenter());
		
		flying = !bodyTouchingSlope;
		
		if (gamepad != null) 
		{
			var inputForce:B2Vec2 = new B2Vec2(gamepad.x, gamepad.y);
			inputForce.x = 0;
			
			if (mouseDown)
			{
				inputForce.set(0, 0);
				if (stage.mouseY < stage.stageHeight / 3)
				{
					inputForce.y = -1;
				}
				else
				{
					inputForce.y = 1;
				}
			}
			
			var appliedForce:B2Vec2 = inputForce.copy();
			
			
			if (inputForce.y < 0)
			{
				if (circleBody.getLinearVelocity().y > 0)
				{
					appliedForce.y = -6;
				}
				else 
				{
					appliedForce.y = -1;
				}
			}
			else if(inputForce.y > 0)
			{
				flying = false;
				appliedForce.multiply(8);
			}
			else 
			{
				if (circleBody.getLinearVelocity().y > 0)
				{
					appliedForce.y = -4;
				}
			}
			
			
			
			
			/*if (appliedForce.y < 0) 
			{
				if (circleBody.getLinearVelocity().y < 0) 
				{
					appliedForce.y /= 10;
				}
				else 
				{
					appliedForce.y /= 4;
				}
			}*/
			
			
			
			if (appliedForce.y > 0 && circleBody.getLinearVelocity().x > 2) 
			{
				//appliedForce.y = 0;
				if (bodyTouchingSlope) 
				{
					circleBody.applyForce(new B2Vec2(4, 0), circleBody.getWorldCenter());
				}
				else 
				{
					//circleBody.getLinearVelocity().x *= 0.98;
					appliedForce.x = -5;
				}
			}
			
			if (bodyTouchingSlope && circleBody.getLinearVelocity().x < MIN_SPEED) 
			{
				var modifiedVelocity:B2Vec2 = circleBody.getLinearVelocity().copy();
				modifiedVelocity.x = MIN_SPEED;
				circleBody.setLinearVelocity(modifiedVelocity);
				
				
			}
			
			if (bodyTouchingSlope && circleBody.getLinearVelocity().y > 0)
			{
				if (inputForce.y > 0)
				{
					appliedForce.x = Math.sqrt(circleBody.getLinearVelocity().y);
				}
			}
			
			
			circleBody.applyForce(appliedForce, circleBody.getWorldCenter());
			
			var vSpeed:Float = Math.max(circleBody.getLinearVelocity().y, -240);
			
			circleBody.getLinearVelocity().y = vSpeed;
			
			
			//if(chain.length
			
		}
		
		if (bodyTouchingSlope && circleBody.getLinearVelocity().x < 2) 
		{
			var modifiedVelocity:B2Vec2 = circleBody.getLinearVelocity().copy();
			modifiedVelocity.x = 2;
			circleBody.setLinearVelocity(modifiedVelocity);
		}
		
		var modPos:B2Vec2 = circleBody.getPosition().copy();
		var velMod:B2Vec2 = circleBody.getLinearVelocity().copy();
		velMod.multiply(1 / 10);
		//modPos.add(velMod);
		
		chainStart.setPosition(modPos);
		
		if (Lib.getTimer() > kickoffTime && kickoffTime != 0)
		{
			var monsterToKick:B2Body = chain.pop();
			var joint:B2JointEdge = monsterToKick.getJointList();
			while (joint != null)
			{
				world.destroyJoint(joint.joint);
				joint = joint.next;
			}
			monsterToKick.applyImpulse(new B2Vec2( -20, -20), monsterToKick.getWorldCenter());
			monsterToKick.setLinearDamping(0.1);
			monsterToKick.setUserData("dead");
			deadMonsters.push(monsterToKick);
			
			chainEnd = chain.length > 0 ? chain[chain.length - 1] : chainStart;
			
			if (chain.length > 0)
			{
				setKickoffTime();
			}
			else 
			{
				kickoffTime = 0;
			}
		}
		
		for (deadMonster in deadMonsters)
		{
			deadMonster.applyForce(new B2Vec2(0, 20), deadMonster.getWorldCenter());
			if (deadMonster.getWorldCenter().y > 100)
			{
				deadMonsters.remove(deadMonster);
			}
		}
		
		if (chain.length > 0)
		{
			circleBody.applyForce(new B2Vec2( -0.15 * chain.length, 0), circleBody.getWorldCenter());
		}
		
		for (monster in chain)
		{
			monster.applyForce(new B2Vec2( -1, 0), monster.getWorldCenter());
		}
	}
	
	function setKickoffTime() 
	{
		kickoffTime = Lib.getTimer() + Std.int(Math.random() * 3000) + 1500;
	}
	
	function getUserDataForBodyA(contactEdge:B2ContactEdge):Dynamic
	{
		return contactEdge.contact.getFixtureA().getBody().getUserData();
	}
	
	function getUserDataForBodyB(contactEdge:B2ContactEdge):Dynamic
	{
		return contactEdge.contact.getFixtureB().getBody().getUserData();
	}
	
	private function addedToStageHandler(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		gamepad = new Gamepad(stage, false, 1);
		
		stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
	}
	
	private function stage_mouseUpHandler(e:MouseEvent):Void 
	{
		mouseDown = false;
	}
	
	private function stage_mouseDownHandler(e:MouseEvent):Void 
	{
		mouseDown = true;
		//trace("Mouse down");
	}
	
	private function addObjects():Void 
	{
		circleBody = world.createBody(new B2BodyDef());
		circleBody.setType(B2Body.b2_dynamicBody);
		circleBody.setUserData("player");
		
		var fixtureDef:B2FixtureDef = new B2FixtureDef();
		fixtureDef.shape = new B2CircleShape(30/physScale);
		fixtureDef.restitution = 0;
		fixtureDef.density = 0.3;
		fixtureDef.friction = 0;
		circleBody.createFixture(fixtureDef);
		circleBody.setPosition(new B2Vec2(10 / physScale, 0 / physScale));
		circleBody.setLinearVelocity(new B2Vec2(30, -20));
		circleBody.setLinearDamping(0.005);
		//var contactListener:PlayerContactListener = new PlayerContactListener(world);
		//world.SetContactListener(contactListener);
		
		chainStart = world.createBody(new B2BodyDef());
		chainStart.setType(B2Body.b2_dynamicBody);
		
		var fixtureDef:B2FixtureDef = new B2FixtureDef();
		fixtureDef.isSensor = true;
		fixtureDef.shape = new B2CircleShape(30/physScale);
		fixtureDef.restitution = 0;
		fixtureDef.density = 100;
		fixtureDef.friction = 0;
		chainStart.createFixture(fixtureDef);
		chainStart.setPosition(circleBody.getPosition().copy());
		//chainStart.setLinearVelocity(new B2Vec2(30, -20));
		chainStart.setLinearDamping(1);
		chainStart.setFixedRotation(true);
		chainEnd = chainStart;
	}
	
}