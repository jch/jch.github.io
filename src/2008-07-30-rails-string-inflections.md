# Rails String Inflections #

I've been using
[constantize](http://api.rubyonrails.org/classes/ActiveSupport/CoreExtensions/String/Inflections.html#M000488)
to turn strings into Class objects.  Constantize is mixed into the
String class by Rails.  This got me to thinking about other clever
helpers that might be mixed into the string class.  A quick search
through the API did not disappoint.

In
[ActiveSupport::CoreExtensions::String::Inflections](http://api.rubyonrails.org/classes/ActiveSupport/CoreExtensions/String/Inflections.html),
I found a whole list of goodies.  I can find the database table name
for a given class with 'tableize'.  If I just wanted a Class name
string instead of a Class object, I can use 'classify'.  'dasherize'
probably isn't too useful for me, but I thought it was cute.  I can
see 'demodulerize' and 'foreign_key' to be very useful.  'humanize',
'pluralize', 'titleize' could be really useful for manipulating text
before it's rendered for the user.  'underscore' can be used to
calculate paths to files based on their class names.

Here's a quick cheatsheet of all the methods.

<table>
  <tr><th>method</th><th>before</th><th>after</th></tr>
  <tr><td>camelcase   </td><td colspan="2">same as camelize</td></tr>
  <tr><td>camelize    </td><td>i_like/them_camels</td><td>ILike::ThemCamels</td></tr>
  <tr><td>classify    </td><td>fish_and_chips</td><td>FishAndChip</td></tr>
  <tr><td>constantize </td>
      <td colspan="2">classify, then turns it into a class object</td>
  </tr>
  <tr><td>dasherize   </td><td>this_ones_cute</td><td>this-ones-cute</td></tr>
  <tr><td>demodulize  </td><td>Strings::All::This::Class</td><td>Class</td></tr>
  <tr><td>foreign_key </td><td>Namespace::Model</td><td>model_id</td></tr>
  <tr><td>humanize    </td><td>employee_salary_id</td><td>Employee salary</td></tr>
  <tr><td>pluralize   </td><td>sheep</td><td>sheep</td></tr>
  <tr><td>singularize </td><td>sheep</td><td>sheep</td></tr>
  <tr><td>tableize    </td><td>FrenchToast</td><td>french_toasts</td></tr>
  <tr><td>titlecase   </td><td colspan="2">same as titleize</td></tr>
  <tr><td>titleize    </td><td>good night moon</td><td>Good Night Moon</td></tr>
  <tr><td>underscore  </td><td>NameSpace::Model</td><td>name_space/model</td></tr>
</table>
