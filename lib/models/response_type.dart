/// Model class representing the status of data loading operations, i.e. loading remote lectures,
/// and mapping them to the corresponding UI-widgets.
class Response {
  Status status;
  String? message;

  Response.loading(this.message) : status = Status.loading;
  Response.completed() : status = Status.completed;
  Response.error(this.message) : status = Status.error;

  @override
  String toString() {
    return 'Response{status: $status, message: $message}';
  }
}

enum Status { loading, completed, error }