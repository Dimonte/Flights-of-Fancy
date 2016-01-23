package actionCore;
import box2D.dynamics.B2ContactImpulse;
import box2D.dynamics.B2ContactListener;
import box2D.dynamics.contacts.B2Contact;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */

class ContactListenerProxy extends B2ContactListener
{

	public function new() 
	{
		super();
	}
	
	override public function postSolve(contact:B2Contact, impulse:B2ContactImpulse):Void 
	{
		super.postSolve(contact, impulse);
		
	}
	
}