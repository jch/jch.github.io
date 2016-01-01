# Ruby Python Cheatsheet #

Some equivalents for my reference:

<table>
  <tr>
    <th>Ruby</th>
    <th>Python</th>
    <th>Comment</th>
  </tr>

  <tr>
    <td>Rubygems</td>
    <td>Eggs</td>
    <td>python setuptools, utility is called easy_install</td>
  </tr>

  <tr>
    <td>__FILE__</td>
    <td>???</td>
    <td></td>
  </tr>

  <tr>
    <td>$: or $LOAD_PATH</td>
    <td>import sys; sys.path</td>
    <td></td>
  </tr>

  <tr>
    <td>a ? b : c</td>
    <td>b if a else c</td>
    <td>stupid ternary operator</td>
  </tr>

  <tr>
    <td></td>
    <td>sys.stdout; sys.stderr</td>
    <td></td>
  </tr>

  <tr>
    <td>script/console</td>
    <td>django-admin.py shell</td>
    <td></td>
  </tr>

  <tr>
    <td>restful auth, clearance, auth plugins</td>
    <td>[auth middleware](http://docs.djangoproject.com/en/dev/topics/auth/)</td>
    <td></td>
  </tr>

  <tr>
    <td>before_filter</td>
    <td>[BeforeFilter middleware](http://www.djangosnippets.org/snippets/1306/)</td>
    <td></td>
  </tr>
</table>
