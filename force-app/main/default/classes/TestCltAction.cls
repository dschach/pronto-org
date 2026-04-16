global with sharing class TestCltAction {
  global class TestFeedbackValue {
    @InvocableVariable(label='Comment' description='A short comment from the user.')
    global String comment;
  }

  global class Request {
    @InvocableVariable(label='Feedback' description='Structured feedback collected via the CLT editor.' required=true)
    global TestFeedbackValue feedback;
  }

  global class Response {
    @InvocableVariable(label='Message' description='Confirmation message.')
    global String message;

    @InvocableVariable(label='Success' description='True if successful.')
    global Boolean success;
  }

  @InvocableMethod(label='Test CLT Action' description='Simple action to test CLT rendering.')
  public static List<Response> run(List<Request> requests) {
    List<Response> out = new List<Response>();
    for (Request req : requests) {
      Response r = new Response();
      r.success = true;
      String comment = (req != null &&
        req.feedback != null &&
        req.feedback.comment != null)
        ? req.feedback.comment
        : '(empty)';
      r.message = 'Received: ' + comment;
      out.add(r);
    }
    return out;
  }
}