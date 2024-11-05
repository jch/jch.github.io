# Progressive HTML Currency Input

When entering a money value, I like to see the number in my locale. For example, `1000000` is easier to read as `$1,000,000`, but a German would expect `1.000.000 €`. There are many different approaches spanning a decade+ of internet posts. This post talks about the difference approaches and tradeoffs, and what I implemented for my app https://jch.app.

## Context

In my app, users can enter a financial independence goal and their annual expenses. These numbers can be thousands or millions, so it's more readable to have a currency symbol and some separators. My goals are:

- Form submits a numeric value
- Cursor doesn't jump around when user is editing the value
- Preview a formatted currency

## 1. Basic HTML input

`<input type="number" />` has built-in browser validation and a numeric keyboard on mobile. The step controls make sense if you want to make it easy for users to go up or down by $1 or $0.01, but different people have very different FI numbers and annual expenses.

From the [MDN docs](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/number#using_number_inputs):

> The number input type should only be used for incremental numbers, especially when spinbutton incrementing and decrementing are helpful to user experience. The number input type is not appropriate for values that happen to only consist of numbers but aren't strictly speaking a number, such as postal codes in many countries or credit card numbers.

`<input type="text" inputmode="decimal />` still gives a numeric keyboard on mobile, but skips the step controls. I started with this, but ran into readability issues for bigger numbers.

## 2. Choose a common value

A donation site might have buttons for $5, $10, $20, $100, and a custom donation amount. This makes sense if you want to anchor a user to some suggested value. It's also helpful if it helps users do some calculation like a percentage based tip. I thought about making a default like $1MM for an FI goal, but again, I didn't think it was better to have a default value.

## 3. Masking with a formatted value

There are a lot of libraries that format currency as a user types (see notes). React seems the most popular at the moment (2024), but there are posts for jQuery from a decade ago. Looking at the source for these libraries was helpful:

- Setting an input's value resets it's cursor position to the end
- Attempts to maintain cursor position programmatically while formatting the same text is complex, buggy, and brittle

Banking apps have the best implementation of this approach. To prevent the cursor jumping around while editing, they force the cursor to the beginning or the end.

Bank of America starts the cursor at the end. As you enter numbers, the cursor stays at the end and fills in each digit from right to left ($0.01 $0.12 $1.23 $12.34) Weirdly, it also lets you move the cursor to the front, but it jumps back to the end when you enter a number ($0.00, enter a 2 gives you $20.00 and the cursor is at the end again.)

Paypal's approach feels more intuitive. It starts the cursor at the beginning ($), adding commas as you type left to right ($1 $12 $123 $1,234). It forbids you from moving the cursor to change the middle. You have to delete to go back, and it updates any separators as you edit.

While I like PayPal's experience in a native context, I don't want to fight the browser and try to override the cursor position.

## 4. Preview formatted money when not editing

A variant to masking with a formatted value, separating the visual formatted value from the input's number value simplifies the implementation, but isn't as intuitive for user experience. My favorite example of this is in spreadsheets. A cell with a numeric value can be formatted in different ways, but the underlying value is still a number. When you edit the cell, there are no separators. Only when you finish editing (cell loses focus), does the value get formatted.

Here's one implementation that does this, but reusing the same form control means that the server has to parse the formatted value back to a number. The React component kept separate state for the formatted value and the raw number value.

```html
<label>
  <p>Try entering some long and short numbers...</p>
  <input class="currency" inputmode="decimal" type="text" value="1234.56" style="padding: 0.5em; font-size: 1.2em">
</label>
```

```js
<script id="currencyJs" type="module">
  const iso_4217 = {
    'en-US': 'USD',
    'en-GB': 'GBP',
    'de-DE': 'EUR',
    'fr-FR': 'EUR',
    'es-ES': 'EUR',
    'it-IT': 'EUR',
    'ja-JP': 'JPY',
    'zh-CN': 'CNY',
    'ko-KR': 'KRW',
    'ru-RU': 'RUB',
    'ar-SA': 'SAR',
    'hi-IN': 'INR',
    'pt-BR': 'BRL',
    'tr-TR': 'TRY',
    'nl-NL': 'EUR',
    'pl-PL': 'PLN',
    'th-TH': 'THB',
    'vi-VN': 'VND',
    'id-ID': 'IDR',
    'ms-MY': 'MYR',
  };

  const CurrencyInput = class {
    constructor(element) {
      this.element = element;
      this.locale = navigator.language || navigator.userLanguage || 'en-US';
      this.element.addEventListener('blur', this.format.bind(this));
      this.element.addEventListener('focus', this.unformat.bind(this));
      this.format();
    }

    get formatter() {
      return new Intl.NumberFormat(this.locale, {
        style: "currency",
        currency: iso_4217[this.locale] || 'USD',
      });
    }

    format() {
      this.raw = this.element.value;

      if (!isNaN(this.element.value)) {
        this.element.value = this.formatter.format(this.element.value);
      }
    }

    unformat() {
      this.element.value = this.raw;
    }
  };

  new CurrencyInput(document.querySelector('.currency'));
</script>
```

## 5. Form submits a number

To submit a number and display a formatted value, I create a 2nd input element and toggle the visibility on focus and blur. The formatted input does not have a `name` attribute, so it is not submitted with the form, while the original input keeps the number value. This is more complex, but keeps the changes localized at the input element so the form does not need to be aware. It's also a progressive enhancement of the original input, allowing it to work without javascript.

<img src="/images/currency-input.gif" width="220" height="480" />

## Conclusion

The separation of the numeric value for form submission from visual presentation is key. Trying to maintain the state of both through input.value isn’t sufficient. React has a advantage here for managing state, and I'm following a simliar pattern by maintaining the number state and formatted state in the DOM.

Similar to the approach detailed in the notes, I format as a currency when an input loses focus, and switch back to the raw value when the input is being edited. The increased complexity of maintaining cursor position was not worth the improvement in user experience.


## Notes

- `navigator.language` is widely available for locale information
- ISO 4217 defines currency codes by locale
- `Intl.NumberFormat` and `Number.prototype.toLocaleString` can format numbers as locale-aware currencies
- https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#concept-textarea/input-selection cursor position on input update
- Why not use a number input type? https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/number#using_number_inputs
- Format onblur, use real value when editing: https://levelup.gitconnected.com/creating-a-localized-currency-input-in-react-without-libraries-or-bugs-2f186124aedc?gi=b8408a661baa
- Cursor position arithmetic, too complex to maintain: https://stackoverflow.com/a/39279790
- https://github.com/toarm/number-format?tab=readme-ov-file web component for display, but not an extension on input
- https://github.com/IngressoRapidoWebComponents/money-input?tab=readme-ov-file web component on input, has cursor position issue
- https://devtoolstips.org/tips/en/inspect-user-agent-dom/
- Forcing input cursor to the end: https://stackoverflow.com/questions/511088/use-javascript-to-place-cursor-at-end-of-text-in-text-input-element
- Replacing the input’s value on change puts the cursor at the end of the input, while using setRangeText gives more control over where the cursor lands. Attempts to solve this programmatically with arithmetic on `input.selectionStart` and `input.selectionEnd` are brittle.
