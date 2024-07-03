defmodule EvaluateAwsTranslate do
  @moduledoc false

  alias AWS.Translate

  @finch Application.compile_env(:evaluate_aws_translate, :finch)

  @source_language "en"
  @target_languages ["es-MX", "ht", "pt-PT", "vi", "zh", "zh-TW"]

  def client do
    aws_access_key_id = Application.get_env(:evaluate_aws_translate, :aws_access_key_id)
    aws_secret_access_key = Application.get_env(:evaluate_aws_translate, :aws_secret_access_key)

    AWS.Client.create(aws_access_key_id, aws_secret_access_key, "us-east-1")
    |> AWS.Client.put_http_client({AWS.HTTPClient.Finch, finch_name: @finch})
  end

  def import_terminology(path) do
    input = %{
      "Description" => terminology_description(path),
      "MergeStrategy" => "OVERWRITE",
      "Name" => terminology_name(path),
      "TerminologyData" => %{
        "Directionality" => "UNI",
        "File" => path |> File.read!() |> Base.encode64(),
        "Format" => "CSV"
      }
    }

    {:ok, result, _} = client() |> Translate.import_terminology(input)

    result
  end

  def target_languages, do: @target_languages

  def translate_document(document, terminologies \\ [], target_languages \\ @target_languages)

  def translate_document(content, terminologies, target_languages) when is_list(target_languages) do
    source = %{
      @source_language => content
    }

    Enum.reduce(target_languages, source, fn target_language, results ->
      result = translate_document(content, terminologies, target_language)

      Map.put(results, target_language, result)
    end)
  end

  def translate_document(content, terminologies, target_language) when is_binary(target_language) do
    input = %{
      "Document" => %{
        "Content" => Base.encode64(content),
        "ContentType" => "text/html"
      },
      "SourceLanguageCode" => @source_language,
      "TargetLanguageCode" => target_language,
      "TerminologyNames" => terminologies
    }

    {:ok, result, _} = client() |> Translate.translate_document(input)

    Base.decode64!(result["TranslatedDocument"]["Content"])
  end

  def translate_text(text, terminologies \\ [], target_languages \\ @target_languages)

  def translate_text(text, terminologies, target_languages) when is_list(target_languages) do
    source = %{
      @source_language => text
    }

    Enum.reduce(target_languages, source, fn target_language, results ->
      result = translate_text(text, terminologies, target_language)

      Map.put(results, target_language, result)
    end)
  end

  def translate_text(text, terminologies, target_language) when is_binary(target_language) do
    input = %{
      "SourceLanguageCode" => @source_language,
      "TargetLanguageCode" => target_language,
      "TerminologyNames" => terminologies,
      "Text" => text
    }

    {:ok, result, _} = client() |> Translate.translate_text(input)

    result["TranslatedText"]
  end

  defp terminology(path) do
    path
    |> String.split("/")
    |> List.last()
    |> String.split(".")
    |> List.first()
  end

  defp terminology_description(path) do
    path
    |> terminology()
    |> String.capitalize()
    |> String.replace("-", " ")
  end

  defp terminology_name(path) do
    path
    |> terminology()
    |> String.upcase()
    |> String.replace("-", "_")
  end
end
