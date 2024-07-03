# EvaluateAwsTranslate

The purpose of this project is to evaluate AWS Translate as a backend provider of translations for a translation management service.

## Run this Livebook

1. Use [asdf](https://asdf-vm.com) to install Elixir.
2. Use [direnv](https://direnv.net) to load your AWS credentials.
3. Install [livebook](https://livebook.dev).
4. Start the application `iex --sname evaluate-aws-translate --cookie foobarbaz -S mix`
5. Load the evaluate-aws-translate notebook and [connect to it](https://fly.io/docs/elixir/advanced-guides/interesting-things-with-livebook/#connect-to-your-project).

## Evaluation

AWS Translate has three methods of translation.

### Real-time Translation

The simplest way to translate is synchronously.
You can send either text or a document and get a real-time response.
But, you can only translate from one language to one language at a time.
If you want to translate from English into six languages, you'll have to make six separate requests.
The pricing structure for AWS Translate is based on characters translated so this limitation won't affect costs.

#### Real-time Text Translation

Text translations are limited to 10,000 bytes.
Depending on your character encoding (ex. UTF-8) this means a limit of 10,000 characters at a time.
Again, because pricing is based on characters translated rather than requests made, there is no incentive to bundle or break up text for translation.

#### Real-time Document Translation

Docments are limited to 100,000 bytes.
For UTF-8, this would be 100,000 characters.
Documents can be plaintext, Word, or HTML.
The HTML translation preserves the structure of the document which is incredibly useful when you have a lot of dynamic content with links and images.
HTML document translation also respects the `translate='no'` directive which could be useful in retaining branding in English.
E.g., don't translate Massachusetts Bay Transportation Authority.

### Batch Document Translation

You can also translate document to document in batches and the service supports plaintext, Word, and HTML.
Unlike real-time translations, batch translations can target multiple languages.
Though, the pricing is still character-based and the cost per character is the same; there are no cost savings.
You go from S3 bucket to S3 bucket so there is some overhead in moving files to and from S3.

Batch translations are probably the best way to bulk translate `.po` files that Elixir apps use via [gettext](https://hexdocs.pm/gettext/Gettext.html).
Though, we would need to have a way of converting to and from `.po` files.

### Custom Terminologies

You can create custom terminologies if you want to make specific translations.
This also supports *not* translating some phrases like 'Massachusetts Bay Transportation Authority'.

The maximum size of a custom terminology is 10 MB.

It can take up to 10 minutes for changes to a custom terminology to affect translations.

Translating using a custom terminology takes 5-6 times longer than translating without one.
But, you're really only going from 75ms to 400ms.
Because we aren't doing on-the-fly translations, I don't see this difference as important.

One major limitation exists with custom terminologies in that you can only use one at a time.
This means that teams can't use an MBTA general custom terminology and then accent it with an application specific one.

Custom terminologies are managed via the API by sending an encoded CSV file.
You can't append new entries as the only update methodology is to overwrite the entire file.
This makes managing custom terminologies both simpler and more difficult.
It's easier to only track one file, but as that file gets larger, it gets harder to manage itself.

### Parallel Data

There is also a concept called parallel data where you can give AWS Translate examples of longer text that you have translated.
This can help inform the style, tone, and word choice of translations.
Parallel data is in the format of a CSV residing in S3 and you use the API to point AWS Translate to the file.

Note, parallel data can only be used in batch translations.

## Summary

AWS Translate has all of the functionality we would need to manage translations.
And, its limitations are very minor.
The biggest hurdle I see any translation effort is getting text out of and into any translation management system in order to be translated.
Just looking at dotcom, we have the Elixir UI elements, React UI elements, dynamic content from Drupal, and Alerts.
The UI elements could be handled in batches and written to files.
The dynamic content would have to stored in some intermediary datastore.
Ideally, we would have a way to version translations over time so that we aren't re-translating text that hasn't changed or not re-translating text when a custom terminology has changed.