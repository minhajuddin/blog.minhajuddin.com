title: Show Rails Flash messages in jquery ajax requests
date: 2014-03-12
tags:
- ajax,
- flash,
- rails
---

In the past I struggled with having a consistent strategy for showing error messages in javascript. In rails we usually put the error/success messages in the flash, However if the request is an ajax request the flash doesn't get used and the message shows up on the next page load.

The following code shows error/success messages using the flash properly


~~~ruby
#app/classes/ajax_flash.rb
#include this module in your Applicationcontroller
module AjaxFlash
  extend ActiveSupport::Concern

  included do
    after_filter :add_flash_to_header
  end

  private
  def add_flash_to_header
    # only run this in case it's an Ajax request.
    return unless request.xhr?
    # add flash to header
    response.headers['X-Flash'] = flash.to_h.to_json
    # make sure flash does not appear on the next page
    flash.discard
  end

end
~~~

Include this javascript code

~~~javascript
(function(){
var notifiers, showErrorsInResponse, showFlashMessages;

notifiers = {
  notice: 'success',
  alert: 'error',
  info: 'info'
};

showFlashMessages = function(jqXHR) {
  var flash;
  if (!jqXHR || !jqXHR.getResponseHeader) return;
  flash = jqXHR.getResponseHeader('X-Flash');
  flash = JSON.parse(flash);
  return _.each(flash, function(message, key) {
    return toastr[notifiers[key]](message);
  });
};

showErrorsInResponse = function(jqXHR) {
  var error, response;
  if (!jqXHR || !jqXHR.responseJSON || !jqXHR.responseJSON.errors) return;
  response = jqXHR.responseJSON;
  error = _.map(response.errors, function(messages, property) {
    return _.map(messages, function(x) {
      return "" + property + " " + x;
    }).join("<br />");
  });
  return toastr.error(error, "ERROR");
};

$(function() {
  return $(document).ajaxComplete(function(event, xhr, settings) {
    showFlashMessages(xhr);
    showErrorsInResponse(xhr);
    return xhr.responseJSON.errors;
  });
});
})(this)
~~~

To use this you just need to use your normal code with respond_to

~~~ruby
def create
  @user = User.new(params[:user])
  flash[:notice] = 'User was successfully created.' if @user.save
  respond_with(@user)
end
~~~
