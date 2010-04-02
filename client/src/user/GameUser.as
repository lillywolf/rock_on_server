package user
{
	public class GameUser
	{
		public var _user_id:int;
		public function GameUser()
		{
			_user_id = 1;
		}
		
		public function set user_id(val:int):void
		{
			_user_id = val;
		}
		
		public function get user_id():int
		{
			return _user_id;
		}

	}
}