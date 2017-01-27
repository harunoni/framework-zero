interface {
	public int function count();
	public function sort(required string column, required string direction);
	public array function list(required string max, required string offset);
}