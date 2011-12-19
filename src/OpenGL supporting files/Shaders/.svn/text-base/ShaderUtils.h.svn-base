/*==============================================================================
Copyright (c) 2010-2011 QUALCOMM Austria Research Center GmbH .
All Rights Reserved.
Qualcomm Confidential and Proprietary
==============================================================================*/


#ifndef __SHADERUTILS_H__
#define __SHADERUTILS_H__


#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


class ShaderUtils
{
public:
    // Print a 4x4 matrix
    static void printMatrix(const float* matrix);
    
    // Print GL error information
    static void checkGlError(const char* operation);
    
    // Set the rotation components of a 4x4 matrix
    static void setRotationMatrix(float angle, float x, float y, float z, 
                                  float *nMatrix);
    
    // Set the translation components of a 4x4 matrix
    static void translatePoseMatrix(float x, float y, float z,
                                    float* nMatrix = NULL);
    
    // Apply a rotation
    static void rotatePoseMatrix(float angle, float x, float y, float z, 
                                 float* nMatrix = NULL);
    
    // Apply a scaling transformation
    static void scalePoseMatrix(float x, float y, float z, 
                                float* nMatrix = NULL);
    
    // Multiply the two matrices A and B and write the result to C
    static void multiplyMatrix(float *matrixA, float *matrixB, 
                               float *matrixC);
    
    // Initialise a shader
    static int initShader(GLenum nShaderType, const char* pszSource);
    
    // Create a shader program
    static int createProgramFromBuffer(const char* pszVertexSource,
                                       const char* pszFragmentSource);
};

#endif  // __SHADERUTILS_H__
