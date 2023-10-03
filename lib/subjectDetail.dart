import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'subjectDetailApi.dart';

import 'package:open_file/open_file.dart';
import 'dart:io';
import 'pdfOpen.dart';

class subjectDetail extends StatefulWidget {
  final String data;
  const subjectDetail({super.key, required this.data});

  @override
  State<subjectDetail> createState() => _subjectDetailState();
}

class _subjectDetailState extends State<subjectDetail> {
  void initState() {
    fetchData();
    super.initState();
  }

  List<Detail> data = [];

  Future<void> fetchData() async {
    try{
      final response = await http.get(Uri.parse(
        'https://www.eschool2go.org/api/v1/project/ba7ea038-2e2d-4472-a7c2-5e4dad7744e3?path=${widget.data}'));

    var responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      // Update the state with the API response
      List<Detail> data1 = [];
      responseData!.forEach((element) {
        data1.add(Detail.fromJson(element));
      });

      data1.sort((a, b) => a.title!.compareTo(b.title!));
      setState(() {
        data = data1;
      });
    } else {
      // Handle errors
      print('Failed to load data: ${response.statusCode}');
    }
    }catch(e){
      print(e);
    }
    
  }

  bool loading = false;
  Future<void> downloadAndOpenPDF(String url, String fileName) async {
    setState(() {
      loading = true;
    });
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print("inside started");
        final Directory directory = Directory('/storage/emulated/0/Download');
        final File file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        OpenFile.open('${directory.path}/$fileName');
        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("File Downloaded Successfully in Download Folder")));
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.data),
        ),
        body: data.length > 0 && !loading
            ? ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final subject = data[index];

                  return Card(
                    elevation: 3.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.title.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  final url = subject.downloadUrl.toString();
                                  String fileName = '${subject.title?.substring(3,)}.pdf';
                                  downloadAndOpenPDF(url, fileName);
                                },
                                child: const Text(
                                  "Download",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => pdfOpen(
                                        url: subject.downloadUrl.toString(),
                                        title: subject.title.toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Online",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: CircularProgressIndicator(
                color: Colors.blue,
              )));
  }
}
