  
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:newapp/screens/Gallery.dart';


class Upload extends StatefulWidget {


  
  _UploadState createState() => _UploadState();

}

class _UploadState extends State<Upload> {

    FirebaseFirestore _db=FirebaseFirestore.instance;
  FirebaseStorage _storage=FirebaseStorage.instance;
  List<UploadTask> images=[];

  uploadStorage(File file){
    UploadTask task = _storage.ref().child('images/${DateTime.now().toString()}').putFile(file);
    return task;
  }

  addtoFire(imgurl){
    _db.collection('images').add({"url":imgurl}).whenComplete(() => print('Your task has completed'));
  }
  saveUrltodb(UploadTask task){
     task.snapshotEvents.listen((snapshot) { 
       if(snapshot.state==TaskState.success){
         snapshot.ref.getDownloadURL().then((imgurl)=> addtoFire(imgurl));
       }
     });
  }
  List<File> files =[];
  Future selectfile ()async{
   try{

     FilePickerResult result =await FilePicker.platform.pickFiles(
      allowMultiple: true,type:FileType.image 
     );
     
     if(result !=null){
          files.clear();
          result.files.forEach((selected){
          File file =File(selected.path);
          files.add(file);
          });

      files.forEach((file) {
             final UploadTask task =    uploadStorage( file);
              saveUrltodb(task);
             setState(() {
               images.add(task);
             });
          });
     }
     print('user has cancelled image');


   }
   catch(error){

   }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('Gallery App'),
        actions: [
          IconButton(icon: Icon(Icons.add_a_photo), onPressed:(){
            Navigator.push(context,MaterialPageRoute(
                builder:(context){
                  return GalleryScreen();
                }
            ));
          })
        ],
      
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          selectfile();
        },
        child: Icon(Icons.add),
      ),
      body:images.length>0?ListView.separated(itemBuilder:
         (context,index){
           return StreamBuilder(
             stream:images[index].snapshotEvents,
             builder: (context,snapshot){
                return snapshot.connectionState==ConnectionState.waiting?CircularProgressIndicator():ListTile(
                   title:Text('${snapshot.data.bytesTransferred}')
                );
           });
         },
        separatorBuilder: (context,index)=>Divider(), itemCount:files.length):Center(child:Text('No image is there'))
    );
  }
}