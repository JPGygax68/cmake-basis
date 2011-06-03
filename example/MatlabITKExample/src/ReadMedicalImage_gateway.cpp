/** 
 * @file ReadMedicalImage_gateway.cpp
 * @brief Matlab mex gateway function
 * @author Kayhan Batmanghelich
 * @version 
 * @date 2011-06-02
 */

#include <memory>
using std::auto_ptr;

#include "mex.h" 

#include "ReadMedicalImagePipeline.h"


void mexFunction(int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[])
{
  // input argument check
  if ((nrhs != 1) || 
      !mxIsChar(prhs[0]) ||
      (nrhs == 2 && !mxIsNumeric(prhs[1])) )
    mexErrMsgTxt("Incorrect arguments, see 'help @MATLAB_FUNCTION_NAME@'");

  char* filepath = mxArrayToString(prhs[0]);

  try
    {
    auto_ptr<ReadMedicalImagePipeline> pipeline(new ReadMedicalImagePipeline(filepath));
    size_t m, n, s;
    pipeline->GetSize(m, n, s);

    mwSize dims[3]  ; // = new mwSize[3] ;
    dims[0] = m ;
    dims[1] = n ;
    dims[2] = s ;
    plhs[0] = mxCreateNumericArray(3, dims,  mxDOUBLE_CLASS, mxREAL);
    double* image = (double *)(mxGetData(plhs[0]));
    double* origin=0, *spacing=0;
    switch(nlhs)
      {
    case 1:
      pipeline->CopyAndTranspose(image);
      break;
    case 2:
      plhs[1] = mxCreateDoubleMatrix(3, 1, mxREAL);
      origin = static_cast<double*>(mxGetPr(plhs[1]));
      pipeline->CopyAndTranspose(image, origin);
      break;
    case 3:
      plhs[1] = mxCreateDoubleMatrix(3, 1, mxREAL);
      origin = static_cast<double*>(mxGetPr(plhs[1]));
      plhs[2] = mxCreateDoubleMatrix(3, 1, mxREAL);
      spacing = static_cast<double*>(mxGetPr(plhs[2]));
      pipeline->CopyAndTranspose(image, origin, spacing);
      break;
    default:
      mexErrMsgTxt("Incorrect output arguments.  See 'help @MATLAB_FUNCTION_NAME@'.");
      }
    }
  catch (std::exception& e)
    {
    mexErrMsgTxt(e.what());
    return;
    }
} 


