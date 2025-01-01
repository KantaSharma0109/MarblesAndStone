library config;

import 'dart:async';
import 'dart:io';

import 'package:chef_taruna_birla/models/book.dart';
import 'package:chef_taruna_birla/models/cart_item.dart';
import 'package:chef_taruna_birla/models/slider.dart';
import 'package:chef_taruna_birla/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/course.dart';
import '../models/course_categories.dart';
import '../models/product_categories.dart';
import '../models/products.dart';
import '../models/social_links.dart';
import '../utils/utility.dart';

part '../config/application.dart';
part '../config/constants.dart';
