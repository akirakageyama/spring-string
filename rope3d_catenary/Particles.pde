
class Particles
{
  //
  //                               when N_PARTICLES = 10
  //       ||              y axis
  //       ||                |
  //       \/                |   E ND_POINTS_SEPARATION
  //    gravity in           | /
  //   -y direction          |/
  //                  -------^-------
  //                /        |        \
  //         ------T---------+---------T---------> x axis
  //    triangle #0 \        |        / 9
  //                 T       |       T
  //      triangle #1 \      |      / 8
  //                   T     |     T
  //                  2 \    |    / 7
  //                     T   |   T
  //                    3 \  |  / 6
  //                       T---T
  //                      4  | 5
  //                         |

  float[] posx = new float[N_PARTICLES];
  float[] posy = new float[N_PARTICLES];
  float[] posz = new float[N_PARTICLES];
  float[] velx = new float[N_PARTICLES];
  float[] vely = new float[N_PARTICLES];
  float[] velz = new float[N_PARTICLES];

  int[][] connectedSpringList = new int[N_PARTICLES][6];
            // each particle are connected with 6 springs.
            //
            //    upper layer
            //  (3) (2)
            //   |  /    (1)
            //   | /   o    same
            //   |/ o          layer
            //  (X) o  o  o  (0)
            //    \ \
            //     \  \
            //      \   \
            //     (4)   (5)
            //       lower layer


  final int NULL_MARK = -1; // used to count already set elements.

        //
        //                     o  p=8
        //                  .    .
        //               .         .
        //            .              .
        //         o .   .  .  .  .  . o
        //      p=6                     p=7
        //
        //     p=5                      p=4
        //        o x x x x x x x x x o
        //          x              x
        //            x         x
        //              x    x
        //                 o
        //              p=3
        //                     o  p=2
        //                  .    .
        //               .         .
        //            .              .
        //         o .   .  .  .  .  . o
        //      p=0                     p=1
        //


  Vec3 getBasicTriangleKind01Coord(int nvert)
  {
    //                     z
    //                     |
    //                     | (z,x) = (0,C2)
    //          vertex #2  o
    //                    /|\
    //                   / | \
    //         ------------+---------------> y
    //                 /   |   \
    //      vertex #0 o - -|- - o vertex #1
    //       (-C0,-C1)     |     (C0,-C1)
    //
    final float C0 = EDGE_LENGTH / 2;
    final float C1 = EDGE_LENGTH / (2*sqrt(3.0));
    final float C2 = EDGE_LENGTH / sqrt(3);
    final float C3 = EDGE_LENGTH * sqrt(2.0/3.0);

    final float V0x =   0;
    final float V0y = -C0;
    final float V0z = -C1;
    final float V1x =   0;
    final float V1y =  C0;
    final float V1z = -C1;
    final float V2x =   0;
    final float V2y =   0;
    final float V2z =  C2;

    assert nvert>=0 && nvert<3;

    Vec3 ans = new Vec3(0.0, 0.0, 0.0);

    switch(nvert)
    {
      case 0:
        ans = new Vec3(V0x, V0y, V0z);
        break;
      case 1:
        ans = new Vec3(V1x, V1y, V1z);
        break;
      case 2:
        ans = new Vec3(V2x, V2y, V2z);
        break;
    }

    return ans;
  }

  Vec3 getBasicTriangleKind02Coord(int nvert)
  {
    //
    //           (-C0,C1)       (C0,C1)
    //              #5 o - - - o #4
    //                  \     /
    //                   \   /
    //                    \ /
    //                     o #3
    //            (z,x)=(0,-C2)
    //
    final float C0 = EDGE_LENGTH / 2;
    final float C1 = EDGE_LENGTH / (2*sqrt(3.0));
    final float C2 = EDGE_LENGTH / sqrt(3);
    final float C3 = EDGE_LENGTH * sqrt(2.0/3.0);

    final float V3x =   0;
    final float V3y =   0;
    final float V3z = -C2;
    final float V4x =   0;
    final float V4y =  C0;
    final float V4z =  C1;
    final float V5x =   0;
    final float V5y = -C0;
    final float V5z =  C1;

    assert nvert>=0 && nvert<3;

    Vec3 ans = new Vec3(0.0, 0.0, 0.0);

    switch(nvert)
    {
      case 0:
        ans = new Vec3(V3x, V3y, V3z);
        break;
      case 1:
        ans = new Vec3(V4x, V4y, V4z);
        break;
      case 2:
        ans = new Vec3(V5x, V5y, V5z);
        break;
    }

    return ans;
  }


  void initialConfiguration()
  {
    Vec3[] vertsAtTriangleKind01 = new Vec3[3];
    Vec3[] vertsAtTriangleKind02 = new Vec3[3];

    for (int j=0; j<3; j++) {
      vertsAtTriangleKind01[j] = new Vec3(getBasicTriangleKind01Coord(j));
      vertsAtTriangleKind02[j] = new Vec3(getBasicTriangleKind02Coord(j));
    }

    for (int j=0; j<3; j++) {
      int tl = 0;  // left boundary
      int p = id(tl,j);
      posx[p] = vertsAtTriangleKind01[j].x - ROPE_LENGTH/2;
      posy[p] = vertsAtTriangleKind01[j].y;
      posz[p] = vertsAtTriangleKind01[j].z;
    }

    Vec3 verts;

    float deltaX = TRIANGLE_NATURAL_SEPARATION;

    for (int tl=1; tl<N_TRIANGLES; tl++) {
      float shiftX = - ROPE_LENGTH/2
                     + deltaX * tl;
      for (int j=0; j<3; j++) {
        int p = id(tl,j);
        if ( tl%2==0 ) {
          posx[p] = vertsAtTriangleKind01[j].x + shiftX;
          posy[p] = vertsAtTriangleKind01[j].y;
          posz[p] = vertsAtTriangleKind01[j].z;
        }
        else {
          posx[p] = vertsAtTriangleKind02[j].x + shiftX;
          posy[p] = vertsAtTriangleKind02[j].y;
          posz[p] = vertsAtTriangleKind02[j].z;
        }
      }
    }

    for (int i=0; i<N_PARTICLES; i++) {
      velx[i] = 0.0;
      vely[i] = 0.0;
      velz[i] = 0.0;
    }
  }

  void shiftCenterOfGravityToOrigin()
  {
    float cogx = 0.0;  // center of gravity
    float cogy = 0.0;
    float cogz = 0.0;

    for (int p=0; p<N_PARTICLES; p++) {
      cogx += posx[p];
      cogy += posy[p];
      cogz += posz[p];
    }
    cogx /= float(N_PARTICLES);
    cogy /= float(N_PARTICLES);
    cogz /= float(N_PARTICLES);

    for (int p=0; p<N_PARTICLES; p++) {
      posx[p] -= cogx;
      posy[p] -= cogy;
      posz[p] -= cogz;
    }
  }

  void leftBoundaryConfiguration(float t, int j, float[] yz)
  {

    float angle = (PI*2 / SPRING_CHAR_PERIOD) * twistFactor * t;

    Vec3 basic = getBasicTriangleKind01Coord(j);
    float y0 = basic.y;
    float z0 = basic.z;
    yz[0] =  cos(angle)*y0 + sin(angle)*z0;
    yz[1] = -sin(angle)*y0 + cos(angle)*z0;
  }

  void rightBoundaryConfiguration(float t, int j, float[] yz)
  {
    float angle = -(PI*2 / SPRING_CHAR_PERIOD) * twistFactor * t;
    Vec3 basic;

    if ( N_TRIANGLES%2==0 )
      basic = getBasicTriangleKind02Coord(j);
    else
      basic = getBasicTriangleKind01Coord(j);
    float y0 = basic.y;
    float z0 = basic.z;
    yz[0] =  cos(angle)*y0 + sin(angle)*z0;
    yz[1] = -sin(angle)*y0 + cos(angle)*z0;
  }


  Particles()
  {
    initialConfiguration();

    // shiftCenterOfGravityToOrigin();

    for (int nt=0; nt<N_TRIANGLES; nt++) {
      for (int j=0; j<3; j++) {
        int pid = id(nt,j); // particle id
        for (int s=0; s<6; s++) {  // six springs.
          // each particles is connectd by 6 springs.
          connectedSpringList[pid][s] = NULL_MARK;
        }
      }
    }
  }

  int id(int layerId, int vertexId)
  {
    //  each triangle's              each particle's
    //    vertex id                        id
    // - - - - - - - - - - - - - - - - - - - - - - - - - -
    //
    //        2                             8
    //      .   .       triangle          .   .
    //    0 . . . 1      layerId=2      6 . . . 7
    //
    //
    //   2 . . . 1                     5 . . . 4
    //    .   .         triangle        .   .
    //     0              layerId=1      3
    //
    //
    //        2                             2
    //      .   .       triangle          .   .
    //    0 . . . 1       layerId=0     0 . . . 1
    //
    return 3*layerId + vertexId;
  }


  int[] getConnectedSpingListForThisParticle(int particleId)
  {
    int[] list = new int[6];

    for (int i=0; i<6; i++) {
      list[i] = connectedSpringList[particleId][i];
    }

    return list;
  }


  int numberOfConnectedSpringsToThisParticle(int particleId)
  {
    int ans;

    for (int i=0; i<6; i++) {
      int val = connectedSpringList[particleId][i];
      if ( val==NULL_MARK ) {
        ans = i;
        return ans;
      }
    }
    // alerady set all the six elements.
    ans = 6;
    return ans;
  }


  void connectedSpringsAppend(int particleId, int springid)
  {
    int num = numberOfConnectedSpringsToThisParticle(particleId);

    assert num >=0 && num<6;

    connectedSpringList[particleId][num] = springid;
  }


  void display() {
    noStroke();
    fill(100,0,130);
    for (int p=0; p<N_PARTICLES; p++) {
      pushMatrix();
        float x = posx[p];
        float y = posy[p];
        float z = posz[p];
        translate(mapx(x), mapy(y), mapz(z));
        sphere(3);
      popMatrix();
    }
  }


  float energy()
  {
    float sum = 0.0;
    for (int p=0; p<N_PARTICLES; p++) {
      float vxsq = pow(velx[p],2);
      float vysq = pow(vely[p],2);
      float vzsq = pow(velz[p],2);
      float vsq = vxsq + vysq + vzsq;
      sum += 0.5*PARTICLE_MASS*vsq;
    }
    return sum;
  }

}