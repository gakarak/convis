/*
 * smalllib.cpp
 *
 *  Created on: 28.02.2009
 *      Author: ar
 */

#include "smalllib.h"

#define ERR_MAX_COUNT	5

//int convertAVItoJPEG(const string& file_avi, const string& dir_path) {
int convertAVItoJPEG(const char* file_avi, const char* dir_path) {
	cout << "file=" << file_avi << ",  dir=" << dir_path << endl;
//	CvCapture* capture = cvCreateFileCapture(file_avi.c_str());
	CvCapture* capture = cvCreateFileCapture(file_avi);
	if (capture == 0) {
		cerr << "Error : can't create capture from AVI file [" << file_avi << "]" << endl;
		return ERROR_CREATE_CAPTURE;
	}

	long num_of_frames = 0;
//    cvSetCaptureProperty(capture,CV_CAP_PROP_POS_AVI_RATIO,1.0);
//    long num_of_frames = cvGetCaptureProperty(capture,CV_CAP_PROP_POS_FRAMES);
	//num_of_frames = cvGetCaptureProperty(capture,CV_CAP_PROP_FRAME_COUNT);
	num_of_frames  = 10;
    cout << num_of_frames << endl;
//    cvSetCaptureProperty(capture,CV_CAP_PROP_POS_AVI_RATIO,0.);
    if (num_of_frames < 1) {
    	cerr << "Error : number of frames in capture < 1 [" << num_of_frames << "] " << endl;
    	return ERROR_UNKNOWN;
    }
    cout << "fuck0" << endl;
    CvSize siz = cvSize(
    		cvGetCaptureProperty(capture,CV_CAP_PROP_FRAME_WIDTH),
    		cvGetCaptureProperty(capture,CV_CAP_PROP_FRAME_HEIGHT)
    		);
    cout << "fuck0.5" << endl;
    cout << siz.width << ":" << siz.height << endl;
//    int FPS = cvGetCaptureProperty(capture,CV_CAP_PROP_FPS);
    int FPS = 10;
//    CvVideoWriter* writer = cvCreateVideoWriter(dir_path,CV_FOURCC('P','I','M','1'), FPS, siz,0);
    CvVideoWriter* writer = cvCreateVideoWriter(dir_path,0, FPS, siz,0);
    cout << "fuck1" << endl;
    if(writer==0) {
    	cerr << "Error: can't create VideoWriter for [" << dir_path << "] " << endl;
    	return ERROR_CR_VWRITER;
    }
    int err_count = 0;
    cout << "fuck2" << endl;
    for(int ii=1; ii<num_of_frames; ii++) {
        IplImage* frame = cvQueryFrame(capture);
        if(frame == 0) {
        	cerr << "Error: can't get frame [" << ii << "] from capture " << endl;
        	err_count++;
        	if(err_count>ERR_MAX_COUNT) {
        		return ERROR_QUERY_FRAME;
        	} else {
        		continue;
        	}
        }
        if(cvWriteFrame(writer,frame)!=0) {
        	cerr << "Error: can't write frame [" << ii << "]  to file " << endl;
        	err_count++;
        	if(err_count>ERR_MAX_COUNT) {
        		return ERROR_UNKNOWN;
        	} else {
        		continue;
        	}
        }
        err_count=0;
    }
    cvReleaseVideoWriter(&writer);
    cvReleaseCapture(&capture);
    return 0;
}


void drawCentrafBox(IplImage* img, CvPoint p1, CvPoint p2, CvScalar color, int lw) {
    cvLine(img,
            p1,
            cvPoint(p2.x,p1.y),
            color,lw);
    cvLine(img,
            cvPoint(p2.x,p1.y),
            p2,
            color,lw);
    cvLine(img,
            p2,
            cvPoint(p1.x,p2.y),
            color,lw);
    cvLine(img,
            cvPoint(p1.x,p2.y),
            p1,
            color,lw);
}

void drawSquareBox(IplImage* img, CvPoint p, int l2, CvScalar color, int lw) {
	cvRectangle(img,cvPoint(p.x-l2,p.y-l2),cvPoint(p.x+l2,p.y+l2),color,lw);
}


// dst -> must be freed
int convertArrayFromIntTo2d32F(CvPoint* src, CvPoint2D32f* dst, int siz) {
//#ifdef DEBUG
//	cout << "Create CvPoint array (" << num_x << "x" << num_y << ")" << endl;
//#endif
//	dst = new CvPoint2D32f[siz];
	for(int i=0; i< siz; i++) {
		dst[i] = cvPointTo32f(src[i]);
	}
	return siz;
}

int convertArrayFrom2d32fToInt(CvPoint2D32f* src, CvPoint* dst, int siz) {
	for(int i=0; i< siz; i++) {
		dst[i] = cvPointFrom32f(src[i]);
	}
	return siz;
}

int createPointArray(CvPoint* &array, CvPoint p0, CvPoint p1, CvSize gsize) {
	CvPoint pMin = cvPoint(MIN(p0.x,p1.x),MIN(p0.y,p1.y));
	CvPoint pMax = cvPoint(MAX(p0.x,p1.x),MAX(p0.y,p1.y));

	int num_x = (int)(CV_IABS(pMax.x - pMin.x)/gsize.width);
	int num_y = (int)(CV_IABS(pMax.y - pMin.y)/gsize.height);
	int arr_siz = num_x*num_y;
#ifdef DEBUG
	cout << "Create CvPoint array (" << num_x << "x" << num_y << ")" << endl;
#endif
	array = new CvPoint[arr_siz];
	for(int ii=0; ii<num_x; ii++) {
		for(int jj=0; jj<num_y; jj++) {
			array[ii*num_y+jj] = cvPoint(pMin.x+gsize.width*ii, pMin.y+gsize.height*jj);
		}
	}
	return arr_siz;
}

int createCopyArray(CvPoint* src, CvPoint* &dst, int num_elements) {
#ifdef DEBUG
	cout << "Copy CvPoint array with size (" << num_elements << ")" << endl;
#endif
	dst = new CvPoint[num_elements];
	for(int i=0; i<num_elements; i++) {
		dst[i] = src[i];
	}
	return num_elements;
}

int createCopyArray2D32F(CvPoint2D32f* src, CvPoint2D32f* &dst, int num_elements) {
#ifdef DEBUG
	cout << "Copy CvPoint2D32F array with size (" << num_elements << ")" << endl;
#endif
	dst = new CvPoint2D32f[num_elements];
	for(int i=0; i<num_elements; i++) {
		dst[i] = src[i];
	}
	return num_elements;
}

void releasePointArray(CvPoint* &arr) {
	if (arr!=0) {
#ifdef DEBUG
	cout << "Delete CvPoint array" << endl;
#endif
		delete [] arr;
		arr = 0;
	}
}

void releasePointArray2D32F(CvPoint2D32f* &arr) {
	if (arr!=0) {
#ifdef DEBUG
	cout << "Delete CvPoint2D32F array" << endl;
#endif
		delete [] arr;
		arr = 0;
	}
}

void drawPointsArray(IplImage* img, CvPoint* arr, int siz, CvScalar color) {
	for(int i=0; i<siz; i++) {
		cvLine(img, arr[i],arr[i],color,2);
	}
}



CvPoint2D32f getVelocity(CvPoint2D32f* start, CvPoint2D32f* end, int len){
	CvPoint2D32f* delta = new CvPoint2D32f[len];
	CvPoint2D32f meanV = cvPoint2D32f(0.0,0.0);
	for(int ii=0; ii<len; ii++) {
		delta[ii] = deltaPoints2D32F(start[ii],end[ii]);
		meanV.x += delta[ii].x;
		meanV.y += delta[ii].y;
	}
	meanV.x /=len;
	meanV.y /=len;
	double sx = 0;
	double sy = 0;
	for(int i=0; i<len; i++) {
		sx += (delta[i].x - meanV.x)*(delta[i].x - meanV.x);
		sy += (delta[i].y - meanV.y)*(delta[i].y - meanV.y);
	}
	sx /=len;
	sy /=len;
	sx = sqrt(sx);
	sy = sqrt(sy);

	double vx	= 0.;
	double vy	= 0.;
	int counter_x	= 0;
	int counter_y	= 0;
	for(int i=0; i< len; i++) {
		if (CV_IABS(delta[i].x - meanV.x)<sx) {
			vx += delta[i].x;
			counter_x++;
		}
		if (CV_IABS(delta[i].y - meanV.y)<sy) {
			vy += delta[i].y;
			counter_y++;
		}
	}
	vx /=counter_x;
	vy /=counter_y;
	return cvPoint2D32f(vx,vy);
}

CvPoint2D32f getVelocityPPS(CvPoint2D32f* start, CvPoint2D32f* end, int len, double t0, double t1) {
	CvPoint2D32f tmp = getVelocity(start,end,len);
	double dt = t1 - t0;
	return cvPoint2D32f(tmp.x/dt,tmp.y/dt);
}

void drawVelocity(IplImage* img, CvPoint2D32f vel, CvPoint p0, int siz, CvScalar color, int thick) {
	double v_len = sqrt(vel.x*vel.x + (vel.y)*(vel.y));
	int x = 0,
		y=0;
	if( v_len > 0.001 ) {
		x = (int) ((siz*vel.x)/v_len);
		y = (int) ((siz*vel.y)/v_len);
	}
	drawSquareBox(img,p0,2,CV_RGB(0,0,255),2);
	cvLine(img,p0,cvPoint(p0.x + x, p0.y + y),color,thick);
}


void drawArrow(IplImage* img, CvPoint2D32f p0, CvPoint2D32f p1 , CvScalar color, int thick, double zoom) {

	CvPoint2D32f dv = cvPoint2D32f(zoom*(p1.x-p0.x),zoom*(p1.y-p0.y));
	CvPoint2D32f p1_new = cvPoint2D32f(p0.x + dv.x, p0.y + dv.y);
	double len = sqrt(dv.x*dv.x + dv.y*dv.y);
	double sl = 0;
	if(len<4) {
		sl=4.;
		dv=cvPoint2D32f((sl*dv.x)/len,(sl*dv.y)/len);
	} else {
		sl=(4.+0.05*len);
		dv=cvPoint2D32f((sl*dv.x)/len,(sl*dv.y)/len);
	}
	CvPoint2D32f vla = cvPoint2D32f(
			p1_new.x - dv.x + dv.y,
			p1_new.y - dv.y - dv.x
			);
	CvPoint2D32f vra = cvPoint2D32f(
			p1_new.x - dv.x - dv.y,
			p1_new.y - dv.y + dv.x
			);
	cvLine(img,cvPointFrom32f(p0),cvPointFrom32f(p1_new),color,thick);
	cvLine(img, cvPointFrom32f(p1_new),cvPointFrom32f(vla),color,thick);
	cvLine(img, cvPointFrom32f(p1_new),cvPointFrom32f(vra),color,thick);
}

CvPoint2D32f getOrtoVec(CvPoint2D32f p) {
	return cvPoint2D32f(p.y, -p.x);
}

CvPoint2D32f getCrossPoint(CvPoint2D32f p1, CvPoint2D32f a1, CvPoint2D32f p2, CvPoint2D32f a2 ) {
	double det = -a1.x*a2.y+a2.x*a1.y;
	if (fabs(det) < 0.01) {
		return cvPoint2D32f(-1.,-1.);
	}
	CvPoint2D32f dp = cvPoint2D32f(p2.x-p1.x, p2.y-p1.y);
	double t1 = (-dp.x*a2.y+dp.y*a2.x)/det;
//	double t1 = (dp.x*a1.y-dp.y*a1.x)/det;
	return cvPoint2D32f(p1.x + a1.x*t1, p1.y + a1.y*t1);
}
