import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/image_gallery/image_gallery_state.dart';
import 'package:rits_client/models/gallery/gallery_entry.dart';
import 'package:rits_client/utils/rest_client.dart';
import 'package:rits_client/settings.dart' as settings;

import 'image_gallery.dart';

class ImageGalleryBloc extends Bloc<ImageGalleryEvent, ImageGalleryState> {
  final RestClient restClient;
  final AppContext appContext;

  ImageGalleryBloc({
    @required this.restClient,
    @required this.appContext,
  })  : assert(restClient != null),
        assert(appContext != null),
        super();

  ImageGalleryState get initialState => ImageGalleryUninitialized();

  @override
  Stream<ImageGalleryState> mapEventToState(ImageGalleryEvent event) async* {
    if (event is FetchImages) {
      try {
        final entries = await _fetchGalleryEntries();

        yield ImageGalleryLoaded(
            entries: entries //.where((entry) => !entry.isVideo).toList()
            );
      } on ApiError {
        yield ImageGalleryError();
      }
    }
  }

  Future<List<GalleryEntry>> _fetchGalleryEntries() async {
    // return [
    //   'https://habrastorage.org/webt/4e/tj/ed/4etjed_wbzdwjg3u90w4lhu_irg.png',
    //   'https://habrastorage.org/webt/yy/ja/6c/yyja6czvwgohgpaoezrpt0b35rg.jpeg',
    //   'https://habrastorage.org/webt/c_/qt/lv/c_qtlvsh2qbeqcmpsvmrj4idbuu.jpeg',
    //   'https://habrastorage.org/webt/if/7t/n-/if7tn-gbfmclj28lr21z2y0jjtc.jpeg',
    //   'https://habrastorage.org/webt/rv/bh/ky/rvbhkysbvfjn8ykkze1srkpmsha.png',
    //   'https://habrastorage.org/webt/an/r8/8j/anr88ju9vtr97gbe1rhoz3yhfmm.jpeg',
    //   'https://habrastorage.org/webt/o_/ra/lm/o_ralmbmtdwlceq_sdjfizvh8gk.png',
    //   'https://habrastorage.org/webt/vv/qm/zb/vvqmzbqcr0fjgvtglynonrzrvlo.jpeg',
    //   'https://sun1-14.userapi.com/c856520/v856520644/4502/s9by3WPE5kE.jpg',
    //   'https://habrastorage.org/webt/le/oi/ue/leoiuedk-eypbgbuvoleyqau96w.jpeg',
    //   'https://habrastorage.org/webt/23/z9/fc/23z9fcqkxo3eenj7h32xryu0kgs.jpeg',
    //   'https://habrastorage.org/getpro/habr/post_images/a18/491/04f/a1849104f0319f36d0dd9322f5778bfa.jpg',
    //   'https://habrastorage.org/webt/o9/my/za/o9myzazifu9xgs8skgekpj0yqv4.jpeg',
    //   'https://habrastorage.org/webt/yp/wj/re/ypwjre0s5e1kq92cxiqsfjtwmfa.png',
    //   'https://habrastorage.org/webt/7v/hx/vd/7vhxvdz2xfn7-cqngdfugjd6d7k.jpeg',
    //   'https://habrastorage.org/webt/9a/lj/ke/9aljkep6gt7ikne0ynbo5owhjui.jpeg',
    //   'https://habrastorage.org/webt/vk/yp/do/vkypdodr6vfpk6jtthe4gzaufca.jpeg',
    //   'https://habrastorage.org/webt/xn/xc/mt/xnxcmtltegow57uumxndtikzbdq.png',
    //   'https://habrastorage.org/webt/r-/kx/mm/r-kxmm0fge_nc6xtx0dsyeknwtm.png',
    //   'https://habrastorage.org/webt/up/mk/bi/upmkbinbp-x7iemi5kyqreplvuq.jpeg',
    //   'https://habrastorage.org/webt/mq/vc/8l/mqvc8lv2ywmuipt3lrgtpwpmj0c.jpeg',
    //   'https://habrastorage.org/webt/n2/uw/iz/n2uwizk8rwawv9xezuak4ltsu9s.jpeg',
    //   'https://habrastorage.org/webt/jz/zu/un/jzzuunk1lhxykcm7wzw8abqoaek.png',
    //   'https://habrastorage.org/webt/aj/iy/6u/ajiy6uxuinpiwvqyowzikms-ymc.jpeg',
    //   'https://habrastorage.org/getpro/habr/post_images/e9b/db3/cb2/e9bdb3cb2dd5b9ede08df3443d23fdad.jpg',
    //   'https://habrastorage.org/webt/wo/rd/ex/wordexhsnoxxfshif6xlye2bwsq.png',
    //   'https://habrastorage.org/webt/-b/i_/73/-bi_73lwdxmnzvtveeghrwvtqay.png',
    //   'https://habrastorage.org/getpro/habr/post_images/51e/4fa/969/51e4fa969a3e5ede3b31064499c33226.png',
    //   'https://habrastorage.org/webt/i3/c2/0d/i3c20dobkuqzq9banix7yji4otu.jpeg',
    //   'https://habrastorage.org/webt/hn/ly/y5/hnlyy5b88_sljyfalw7vhvutvpk.jpeg',
    //   'https://habrastorage.org/webt/vv/hm/fq/vvhmfqb2dpw2q8odtzs5ufy_q4o.jpeg',
    // ];

    final url =
        '${settings.backendUrl}/GetGalleryFileList/${appContext.userToken}/False/${appContext.sessionContextName}';
    final response = await restClient.get(url);

    final body = List<Map<String, dynamic>>.from(
        json.decode(response.body)['FilesList'] as List);

    return body.map((entry) {
      return GalleryEntry.fromJson(entry);
    }).toList();
  }
}
