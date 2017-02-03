/**
 * Interface to describe any data that can be used by zerotable
 */
interface {
	public numeric function count();
	public function sort(required string column, required string direction);
	public array function list(required string max, required string offset);
	public void function search(required string searchString);
	// public void function filter(required string filterString);
}