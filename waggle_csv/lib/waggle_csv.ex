defmodule WaggleCsv do

  alias NimbleCSV.RFC4180, as: NiCSV
  alias NimbleCSV.Spreadsheet, as: Spred
  NimbleCSV.define(MyParser, separator: "\t", escape: "\"")

  @moduledoc """
  Documentation for `WaggleCsv`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> WaggleCsv.hello()
      :world

  """
  def read_to_cleansing(csv_file, cleansing_word) do
    csv_file
    |> File.stream!()
    |> Enum.map(& (String.replace( &1, ",", "\t" ) ) ) # CSV -> TSV変換
    |> Enum.map(& (String.replace( &1, "\r\n", "\n" ) ) ) #改行除去
    |> Enum.map(& (String.replace( &1, "\"", "" ) ) ) #ダブルクォーと除去
    |> Enum.map(& (String.replace( &1, " ", "" ) ) )  #半角スペース除去
    |> Enum.map(& (String.replace( &1, "　", "" ) ) ) #全角スペース除去
    |> Enum.map(& (String.replace( &1, cleansing_word, "" ) ) ) #_2022除去
    |> Enum.map(& ( &1 |> String.split( "\t" ) ) )
   end

   def count(csv_file, keyword, header_number) do
     csv_file
     |> File.stream!()
     |> Enum.map(& (String.replace( &1, ",", "\t" ) ) ) # CSV -> TSV変換
     |> Enum.map(& (String.replace( &1, "\r\n", "\n" ) ) ) #改行除去
     |> Enum.map(& (String.replace( &1, "\"", "" ) ) ) #ダブルクォーと除去
     |> Enum.map(& (String.replace( &1, " ", "" ) ) )  #半角スペース除去
     |> Enum.map(& (String.replace( &1, "　", "" ) ) ) #全角スペース除去
     |> Enum.map(& ( &1 |> String.split( "\t" ) ) )
     |> Enum.map(& (Enum.at(&1, header_number )))
     |> Enum.filter(& (&1 == keyword))
     |> Enum.count
    end

   def row_to_list(csv_file, header_number) do
     csv_file
     |> File.stream!()
     |> Enum.map(& (String.replace( &1, " ", "" ) ) )  #半角スペース除去
     |> Enum.map(& (String.replace( &1, "　", "" ) ) ) #全角スペース除去
     |> Enum.map(& (String.replace( &1, "_2022", "" ) ) ) #_2022除去
     |> NiCSV.parse_enumerable
     |> Enum.map(& (Enum.at(&1, header_number )))
   end

   def to_chank(list1, list2) do
     Enum.zip(list1,list2)
     |>Enum.into(%{})
   end

   def read_enumerable(csv_file) do
     csv_file
     |> File.stream!()
     |> NiCSV.parse_enumerable([skip_headers: false])
   end

   def read_header(csv_file) do
     [head | _tail] = csv_file
     |> File.stream!()
     |> NiCSV.parse_enumerable([skip_headers: false])
     head
   end

   def write_csv(filename,data) do
     File.write!(filename, data_to_csv(data))
   end

   defp data_to_csv(data) do
     data
     |>Spred.dump_to_iodata()
   end

   def tuple_to_lists(duble_lists) do
     duble_lists
     |>Enum.map(&tuple_to_list/1)
   end

   defp tuple_to_list({key, map}) do
     [key, map]
   end
end
