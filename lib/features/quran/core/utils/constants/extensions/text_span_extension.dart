import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension TextSpanExtension on String {
  List<TextSpan> buildTextSpans() {
    String text = this;

    // Insert line breaks after specific punctuation marks unless they are within square brackets
    text = text.replaceAllMapped(
      RegExp(r'(\.|\:)(?![^\[]*\])\s*'),
      (match) => '${match[0]}\n',
    );

    final RegExp regExpQuotes = RegExp(r'\"(.*?)\"');
    final RegExp regExpBraces = RegExp(r'\{(.*?)\}');
    final RegExp regExpParentheses = RegExp(r'\((.*?)\)');
    final RegExp regExpSquareBrackets = RegExp(r'\[(.*?)\]');
    final RegExp regExpDash = RegExp(r'\-(.*?)\-');

    final Iterable<Match> matchesQuotes = regExpQuotes.allMatches(text);
    final Iterable<Match> matchesBraces = regExpBraces.allMatches(text);
    final Iterable<Match> matchesParentheses = regExpParentheses.allMatches(
      text,
    );
    final Iterable<Match> matchesSquareBrackets = regExpSquareBrackets
        .allMatches(text);
    final Iterable<Match> matchesDash = regExpDash.allMatches(text);

    final List<Match> allMatches = [
      ...matchesQuotes,
      ...matchesBraces,
      ...matchesParentheses,
      ...matchesSquareBrackets,
      ...matchesDash,
    ]..sort((a, b) => a.start.compareTo(b.start));

    int lastMatchEnd = 0;
    List<TextSpan> spans = [];

    for (final Match match in allMatches) {
      if (match.start >= lastMatchEnd && match.end <= text.length) {
        final String preText = text.substring(lastMatchEnd, match.start);
        final String matchedText = text.substring(match.start, match.end);
        final bool isBraceMatch = regExpBraces.hasMatch(matchedText);
        final bool isParenthesesMatch = regExpParentheses.hasMatch(matchedText);
        final bool isSquareBracketMatch = regExpSquareBrackets.hasMatch(
          matchedText,
        );
        final bool isDashMatch = regExpDash.hasMatch(matchedText);

        if (preText.isNotEmpty) {
          spans.add(TextSpan(text: preText));
        }

        TextStyle matchedTextStyle;
        if (isBraceMatch) {
          matchedTextStyle = TextStyle(
            color: Get.theme.colorScheme.primary,
            fontFamily: 'uthmanic2',
          );
        } else if (isParenthesesMatch) {
          matchedTextStyle = TextStyle(
            color: Get.theme.colorScheme.primary,
            fontFamily: 'uthmanic2',
          );
        } else if (isSquareBracketMatch) {
          matchedTextStyle = TextStyle(
            color: Get.theme.colorScheme.inverseSurface,
          );
        } else if (isDashMatch) {
          matchedTextStyle = TextStyle(
            color: Get.theme.colorScheme.inverseSurface,
          );
        } else {
          matchedTextStyle = TextStyle(
            color: Get.theme.colorScheme.inverseSurface,
            fontFamily: 'naskh',
          );
        }

        spans.add(TextSpan(text: matchedText, style: matchedTextStyle));

        lastMatchEnd = match.end;
      }
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return spans;
  }

  Widget buildTextString() {
    String text = this;

    // Insert line breaks after specific punctuation marks unless they are within square brackets
    text = text.replaceAllMapped(
      RegExp(r'(\.|\:)(?![^\[]*\])\s*'),
      (match) => '${match[0]}\n',
    );

    final RegExp regExpQuotes = RegExp(r'\"(.*?)\"');
    final RegExp regExpBraces = RegExp(r'\{(.*?)\}');
    final RegExp regExpParentheses = RegExp(r'\((.*?)\)');
    final RegExp regExpSquareBrackets = RegExp(r'\[(.*?)\]');
    final RegExp regExpDash = RegExp(r'\-(.*?)\-');

    final Iterable<Match> matchesQuotes = regExpQuotes.allMatches(text);
    final Iterable<Match> matchesBraces = regExpBraces.allMatches(text);
    final Iterable<Match> matchesParentheses = regExpParentheses.allMatches(
      text,
    );
    final Iterable<Match> matchesSquareBrackets = regExpSquareBrackets
        .allMatches(text);
    final Iterable<Match> matchesDash = regExpDash.allMatches(text);

    final List<Match> allMatches = [
      ...matchesQuotes,
      ...matchesBraces,
      ...matchesParentheses,
      ...matchesSquareBrackets,
      ...matchesDash,
    ]..sort((a, b) => a.start.compareTo(b.start));

    int lastMatchEnd = 0;
    List<TextSpan> spans = [];

    for (final Match match in allMatches) {
      if (match.start >= lastMatchEnd && match.end <= text.length) {
        final String preText = text.substring(lastMatchEnd, match.start);
        final String matchedText = text.substring(match.start, match.end);
        final bool isBraceMatch = regExpBraces.hasMatch(matchedText);
        final bool isParenthesesMatch = regExpParentheses.hasMatch(matchedText);
        final bool isSquareBracketMatch = regExpSquareBrackets.hasMatch(
          matchedText,
        );
        final bool isDashMatch = regExpDash.hasMatch(matchedText);

        if (preText.isNotEmpty) {
          spans.add(
            TextSpan(
              text: preText,
              style: TextStyle(color: Get.theme.colorScheme.inversePrimary),
            ),
          );
        }

        TextStyle matchedTextStyle;
        if (isBraceMatch) {
          matchedTextStyle = TextStyle(
            color: Get.theme.colorScheme.primary,
            fontFamily: 'uthmanic2',
          );
        } else if (isParenthesesMatch) {
          matchedTextStyle = TextStyle(
            color: Get.theme.colorScheme.primary,
            fontFamily: 'uthmanic2',
          );
        } else if (isSquareBracketMatch) {
          matchedTextStyle = TextStyle(
            color: Get.theme.colorScheme.inverseSurface,
          );
        } else if (isDashMatch) {
          matchedTextStyle = TextStyle(
            color: Get.theme.colorScheme.inverseSurface,
          );
        } else {
          matchedTextStyle = TextStyle(
            color: Get.theme.colorScheme.inverseSurface,
            fontFamily: 'naskh',
          );
        }

        spans.add(TextSpan(text: matchedText, style: matchedTextStyle));

        lastMatchEnd = match.end;
      }
    }

    if (lastMatchEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastMatchEnd),
          style: TextStyle(color: Get.theme.colorScheme.inversePrimary),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(
          fontSize: 16.0,
          color: Get.theme.colorScheme.inversePrimary,
        ),
      ),
    );
  }
}
